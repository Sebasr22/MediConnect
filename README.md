# MediConnect 🏥

## Características Principales

### Funcionalidades para Pacientes
- Exploración y búsqueda de doctores por especialidad
- Visualización de perfiles médicos con información detallada
- Sistema de filtros para encontrar especialistas específicos
- Interfaz intuitiva para navegar entre doctores

### Funcionalidades para Doctores  
- Dashboard personalizado con métricas de citas
- Gestión completa del calendario de citas
- Creación y programación de nuevas citas
- Filtros por rango de fechas para organizar la agenda
- Estadísticas visuales de la actividad médica

### Características Técnicas
- Almacenamiento seguro de credenciales
- Manejo robusto de errores y estados de carga
- Interfaz responsive que se adapta a diferentes tamaños de pantalla
- Implementación completa de Clean Architecture

## Stack Tecnológico

```yaml
# Dependencias principales
flutter_bloc                 # Gestión de estado reactiva
go_router                    # Navegación declarativa
dio                          # Cliente HTTP con interceptors
flutter_secure_storage       # Almacenamiento encriptado
get_it                       # Inyección de dependencias
```

**Por qué estas tecnologías:**
- **BLoC Pattern**: Para una gestión de estado predecible y testeable
- **Go Router**: Navegación declarativa que facilita deep linking
- **Dio**: Cliente HTTP robusto con manejo de interceptors y errores
- **Get It**: Inyección de dependencias limpia y eficiente

## Configuración del Proyecto

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/Sebasr22/MediConnect.git
   cd MediConnect
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Generar código automático**
   
   El proyecto utiliza code generation para los modelos JSON:
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## Credenciales de Prueba

Para probar la aplicación, utiliza estas credenciales:

**Cuenta de Paciente:**
- Email: `usuario-2@mail.com`
- Contraseña: `Usuario-1`

**Cuenta de Doctor:**
- Email: `usuario-3@mail.com`
- Contraseña: `Usuario-1`

## Arquitectura del Proyecto

Implementé Clean Architecture para mantener la separación de responsabilidades y facilitar el testing:

```
lib/
├── core/                 # Lógica compartida
│   ├── error/           # Manejo centralizado de errores
│   ├── navigation/      # Configuración de rutas
│   ├── network/         # Cliente HTTP personalizado
│   ├── storage/         # Capa de persistencia
│   └── utils/           # Utilidades y configuración
├── features/            # Módulos por funcionalidad
│   ├── auth/           # Autenticación
│   ├── patient/        # Funcionalidades de paciente
│   └── doctor/         # Funcionalidades de doctor
```

### Decisiones de Arquitectura

**Clean Architecture + BLoC:**
- **Presentation**: Widgets y BLoCs para manejo de UI y estado
- **Domain**: Entidades y casos de uso con lógica de negocio
- **Data**: Modelos, fuentes de datos y repositorios

**Beneficios obtenidos:**
- Código altamente testeable
- Separación clara de responsabilidades  
- Facilidad para agregar nuevas características
- Mantenimiento simplificado

## Solución de Problemas

### Errores Comunes y Soluciones

**Error en code generation:**
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Problemas de dependencias:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**App se queda en pantalla de carga:**
- Usa las credenciales de prueba exactas
- Verifica conexión a internet
- La API puede tardar unos segundos en responder

## Decisiones Técnicas Destacadas

Durante el desarrollo tomé decisiones arquitectónicas específicas:

1. **Arquitectura de Estado**: Implementé BLoCs separados (Auth, Patient, Doctor) con comunicación a través del sistema de logout para evitar contaminación de datos entre usuarios.

2. **Navegación Adaptativa**: Configuré GoRouter para redirigir automáticamente según el tipo de usuario autenticado, simplificando la UX.

3. **Manejo de Errores Robusto**: Implementé estados de error específicos en cada BLoC y fallbacks UI para mantener la app estable.

4. **Inyección de Dependencias Avanzada**: Configuré GetIt con factories para los BLoCs y singletons para los servicios, permitiendo re-registro dinámico cuando es necesario.

## Contacto

**Sebastián Rodríguez**  
[GitHub](https://github.com/Sebasr22) | [LinkedIn](https://linkedin.com/in/tu-perfil)