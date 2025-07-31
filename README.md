# 🏥 MediConnect

Una aplicación móvil moderna para gestionar citas médicas que conecta pacientes y doctores de manera eficiente.

## 📱 Características

### Para Pacientes
- 🔍 **Búsqueda de doctores** por nombre y especialidad
- 📋 **Lista completa de doctores** con información detallada
- ⭐ **Calificaciones y especialidades** visibles
- 📞 **Información de contacto** de los doctores
- 🎯 **Filtros por especialidad** para búsqueda rápida

### Para Doctores
- 📊 **Dashboard con estadísticas** de citas
- 📅 **Gestión de citas** por fecha
- ➕ **Creación de nuevas citas**
- 🗓️ **Filtros de fecha** personalizables
- 📈 **Estadísticas visuales** de la actividad

### Características Generales
- 🔐 **Autenticación segura** para pacientes y doctores
- 🎨 **Interfaz moderna** con Material Design 3
- 📱 **Responsive design** adaptado a diferentes pantallas
- 🔄 **Manejo de estados** con BLoC pattern
- 🏗️ **Clean Architecture** para mantenibilidad

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework de desarrollo multiplataforma
- **Dart** - Lenguaje de programación
- **BLoC Pattern** - Gestión de estado
- **Go Router** - Navegación declarativa
- **Dio** - Cliente HTTP para APIs
- **Flutter Secure Storage** - Almacenamiento seguro
- **Get It** - Inyección de dependencias
- **Equatable** - Comparación de objetos
- **JSON Serializable** - Serialización automática

## 🚀 Instalación y Configuración

### Prerrequisitos

Antes de ejecutar la aplicación, asegúrate de tener instalado:

- **Flutter SDK** (versión 3.0 o superior)
- **Dart SDK** (incluido con Flutter)
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Git** para clonar el repositorio

#### Verificar instalación de Flutter:
```bash
flutter doctor
```

### 📥 Clonar el Repositorio

```bash
git clone https://github.com/Sebasr22/MediConnect.git
cd MediConnect
```

### 📦 Instalar Dependencias

```bash
flutter pub get
```

### 🔧 Generar Archivos Automáticos

La aplicación utiliza code generation para modelos JSON. Ejecuta:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 📱 Ejecutar la Aplicación

#### En Android:
```bash
flutter run
```

#### En iOS (solo en macOS):
```bash
flutter run
```

#### En Web:
```bash
flutter run -d chrome
```

## 🎯 Credenciales de Prueba

Para probar la aplicación, puedes usar estas credenciales:

### Paciente:
- **Email:** `usuario-2@mail.com`
- **Contraseña:** `Usuario-1`

### Doctor:
- **Email:** `juan@example.com`
- **Contraseña:** `mysecurepassword`

## 🌐 API Backend

La aplicación se conecta a un backend desplegado en:
- **Base URL:** `http://164.92.126.218:3000`

### Endpoints principales:
- `POST /auth/login` - Iniciar sesión
- `POST /auth/register` - Registrar usuario
- `GET /patients/doctors` - Obtener lista de doctores
- `GET /patients/doctors/{id}` - Detalles de doctor específico
- `GET /doctors/{id}/appointments` - Citas de un doctor
- `POST /doctors/{id}/appointments` - Crear nueva cita

## 🏗️ Arquitectura del Proyecto

El proyecto sigue los principios de **Clean Architecture** y utiliza el patrón **BLoC** para la gestión de estado:

```
lib/
├── core/                    # Funcionalidades compartidas
│   ├── error/              # Manejo de errores
│   ├── navigation/         # Configuración de rutas
│   ├── network/            # Cliente HTTP
│   ├── storage/            # Almacenamiento seguro
│   └── utils/              # Utilidades y constantes
├── features/               # Características de la aplicación
│   ├── auth/               # Autenticación
│   │   ├── data/          # Models, DataSources, Repositories
│   │   ├── domain/        # Entities, Use Cases, Repositories
│   │   └── presentation/  # BLoC, Pages, Widgets
│   ├── patient/           # Funcionalidades de pacientes
│   └── doctor/            # Funcionalidades de doctores
└── main.dart              # Punto de entrada
```

### Capas de la Arquitectura:

1. **Presentation Layer**: Widgets, Pages, BLoCs
2. **Domain Layer**: Entities, Use Cases, Repository Interfaces
3. **Data Layer**: Models, Data Sources, Repository Implementations

## 🔧 Solución de Problemas

### Problemas Comunes:

#### Error al generar archivos .g.dart:
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### Error de dependencias:
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

#### La app se queda en la pantalla de carga:
- Usa el botón de **papelera roja** (🗑️) en el dashboard para limpiar datos
- O limpia los datos de la app desde configuración del dispositivo

#### Error de conexión con la API:
- Verifica que tengas conexión a internet
- La API está desplegada en `http://164.92.126.218:3000`

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Contacto

**Desarrollador:** Sebastián Rodríguez
**GitHub:** [https://github.com/Sebasr22](https://github.com/Sebasr22)

---

⭐ Si te gusta este proyecto, ¡dale una estrella en GitHub!