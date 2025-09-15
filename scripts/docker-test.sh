#!/bin/bash

# Script para testear la construcción y ejecución de la imagen Docker
set -e  # Detener script en caso de error

echo "🔨 Iniciando tests de Docker..."
echo "=========================================="

# Variables
IMAGE_NAME="mi-app-python"
CONTAINER_NAME="test-container"
PORT=5000

# Función para limpiar
cleanup() {
    echo "🧹 Limpiando containers anteriores..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
}

# Función para verificar dependencias
check_dependencies() {
    echo "🔍 Verificando dependencias..."
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker no está instalado"
        exit 1
    fi
    echo "✅ Docker está instalado"
}

# Función para construir la imagen
build_image() {
    echo "🏗️  Construyendo imagen Docker..."
    docker build -t $IMAGE_NAME:test .
    echo "✅ Imagen construida exitosamente"
}

# Función para ejecutar tests
run_tests() {
    echo "🐳 Ejecutando container de prueba..."
    
    # Ejecutar container en background
    docker run -d --name $CONTAINER_NAME -p $PORT:5000 $IMAGE_NAME:test
    echo "✅ Container iniciado"
    
    # Esperar a que la app esté lista
    echo "⏳ Esperando a que la aplicación esté lista..."
    sleep 5
    
    # Test health endpoint
    echo "🧪 Testeando endpoint de health..."
    if curl -f http://localhost:$PORT/health; then
        echo "✅ Health check PASSED"
    else
        echo "❌ Health check FAILED"
        exit 1
    fi
    
    # Test main endpoint
    echo "🧪 Testeando endpoint principal..."
    if curl -s http://localhost:$PORT | grep -q "Hola"; then
        echo "✅ Main endpoint PASSED"
    else
        echo "❌ Main endpoint FAILED"
        exit 1
    fi
}

# Función principal
main() {
    echo "🚀 Iniciando tests de Docker para $IMAGE_NAME"
    echo "=========================================="
    
    check_dependencies
    cleanup
    build_image
    run_tests
    
    echo "=========================================="
    echo "🎉 Todos los tests pasaron exitosamente!"
    echo "✅ Image: $IMAGE_NAME:test"
    echo "✅ Container: $CONTAINER_NAME"
    echo "✅ Puerto: $PORT"
    
    # Limpiar después del test
    cleanup
}

# Ejecutar función principal
main "$@"
