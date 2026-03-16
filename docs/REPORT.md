# Reporte — Symmetry Applicant Showcase App

## 1. Introducción

Primero que todo quiero agradecer por haberme dado la oportunidad de realizar esta prueba, ha sido algo muy gratificante y un reto interesante.

Al descargar el proyecto e iniciar el entendimiento de los requerimientos y estructura del código, mi primera reacción fue de entusiasmo mezclado con respeto por la envergadura del reto. Entendí rápidamente que la necesidad inicial era construir una funcionalidad completa de publicación de artículos para periodistas, sobre una base de código existente en Flutter, usando Firebase Firestore como backend, BLoC para el manejo de estado, y Clean Architecture como estructura de capas.

Conocía Flutter previamente, y tenía experiencia con arquitecturas limpias en otros lenguajes. Sin embargo, nunca había trabajado sobre proyecto de flutter ya existente con una arquitectura existente, en mi experiencia como freelancer normalmente todas las aplicaciones que he desarrollado han sido desde 0 y en otros frameworks como Ionic - Capacitor. El reto real no era crear una funcionalidad para publicar artículos, sino adaptarse rápidamente a una situación nueva y salir de la zona de confort.

Mi objetivo desde el inicio fue no solo cumplir los requerimientos mínimos, sino entender la arquitectura del proyecto y construir un MVP sobre esa base de forma coherente.


## 2. Proceso de Aprendizaje

### Flutter BLoC y Cubits
El patrón event/state de BLoC ya era familiar conceptualmente y similar a Redux, pero aprender su implementación específica en Dart especialmente para streams requirió leer la documentación de la librería con detalle. Los Cubits los usé para estado simple para desarrollar el toggle de dark/light theme, mientras que los BLoCs los reservé para flujos más complejos con múltiples eventos.

### Clean Architecture en este proyecto
Leer APP_ARCHITECTURE y ARCHITECTURE_VIOLATIONS varias veces antes de escribir cualquier línea de código fue la mejor inversión de tiempo del proyecto. Tenerlo claro desde el inicio me ayudó a crear conscientemente clases y métodos nuevos.

## 3. Desafíos Encontrados

### 3.1 Incompatibilidad de Flutter Web con SQLite (Floor/sqflite)

Al conectar Firebase al proyecto, descubrí que habían dependencias como sqflite y floor que usan dart:io, que no existe en el navegador web solo para dispositivos nativos y para mejorar la compatibilidad de la app para que en el futuro se pueda usar en la web hice ajustes para no usar estas dependencias en la web y llamar directamente a Firebase y el API de noticias.

No fue un problema bloqueante pero hacía parte del entendimiento del proyecto.

### 3.2 Bugs de compilación encontrados al inicio

Lo primero que pensamos al descargar un proyecto existente es correrlo para ver cómo funciona, pero este proyecto tenía bugs al compilar en la web, lo cual tuve que resolver para tener estabilidad antes de iniciar los cambios.

El más evidente fue un error de compilación en Chrome por `cached_network_image`, que usaba una API de Flutter Web que ya no existe en versiones recientes. Junto con eso el SDK constraint estaba limitado a `<3.0.0`, lo que impedía que pub resolviera paquetes modernos, actualizar eso también fue necesario.

Revisando el código también encontré que varias clases de bloc tenían campos nullable pero los forzaban con `!` en el getter `props` de Equatable. En el flujo normal no crashea porque Equatable compara por tipo primero, pero si se emite el mismo estado dos veces si lanza. Lo corregí cambiando el retorno a `List<Object?>`.

Otro detalle fue que `kDefaultImage`, la constante que se usa como fallback cuando un artículo no tiene imagen, apuntaba a una URL de búsqueda de Google en lugar de una imagen real, así que todos los artículos sin foto mostraban un ícono de error. Lo reemplacé por una URL de placeholder válida.

Por último, `dio` se importaba directamente en varios archivos pero no estaba declarado en `pubspec.yaml`, solo llegaba como dependencia transitiva de `retrofit`. Funciona hoy pero es frágil, así que lo declaré explícitamente.

### 3.3 Dependencias desactualizadas hacen que una app para producción tenga problemas de compilación en android studio

Debido a que este proyecto fue desarrollado hace aprox 1 año, al parecer las dependencias no habían sido actualizadas a nuevas versiones de flutter y dart, en un caso real para publicar esta app en las tiendas play store y app store debemos siempre mantener frameworks actualizados y por ende sus dependencias, además de configuración de compilación para los entornos nativos como la versión de Gradle build en android, además existen requisitos mínimos para poder publicar una app en Google play store por ejemplo el target sdk version o api level actualmente el 35.

Todo se logró actualizar y modificar al momento de hacer el build en android studio y probar la app en un emulador con version de api 35.

Puede encontrar un documento informando las dependencias actualizadas en ./DEPENDENCIES_UPDATED.md

## 4. Reflexión y Direcciones Futuras

### Lo que aprendí
Técnicamente, el proyecto mejoró mi comprensión de Clean Architecture en flutter con múltiples fuentes de datos simultáneas.

Profesionalmente, el desafío más valioso fue leer varias veces la documentación antes de escribir código y, aunque ya hubiera usado flutter y firebase en el pasado, leer y estudiar los tutoriales de nuevo como lo recomendaba la prueba hacen la diferencia, no importa cuántos años de experiencia tengamos siempre hay algo más que aprender.

### Mejoras futuras sugeridas

Creo que el proyecto base es muy básico, si que nos deja trabajo para usar nuestra imaginación pero podría mejorar si se solicita al developer features más complejos que puedan demostrar mucho mejor las capacidades y conocimientos del mismo. Funcionalidades como autenticación de usuarios, búsqueda, manejo de errores de red o paginación son cosas comunes en cualquier app real y exigirlas desde el enunciado daría una mejor idea de como el developer afronta problemas más cercanos a la realidad.

## 5. Evidencia del Proyecto

Puede encontrar las evidencias del funcionamiento del proyecto en el URL compartido de google drive:
https://drive.google.com/drive/folders/1FYc_gbNbyibZfM9vN1JGasd2DVLpMGoD?usp=sharing

---

## 6. Overdelivery

### 6.1 Diseño UI estilo X/Twitter con sistema de tokens de color

El prototipo de Figma original tenía un diseño básico. Rediseñé la interfaz completa siguiendo el lenguaje visual de X (Twitter): paleta oscura con azul #1D9BF0 como color primario, tipografía de peso variable, separadores finos, y tarjetas sin sombras.

Implementé un sistema de tokens de color con clases XColors (modo oscuro) y XLightColors (modo claro), lo que hace que el tema sea mantenible y consistente.

### 6.2 Toggle de tema claro/oscuro

No estaba en los requerimientos. Implementé ThemeCubit para manejar el estado del tema (ThemeMode), con un icono de toggle en el AppBar

### 6.3 Streaming en tiempo real de Firestore

El requerimiento básico era leer artículos de Firestore. Fui más allá implementando un stream en tiempo real con `.snapshots()`, de modo que cuando un periodista publica un artículo, este aparece automáticamente en la lista sin recargar la página. Esto requirió diseñar `WatchFirestoreArticlesUseCase` como un caso de uso de stream (patrón diferente al `UseCase<Future, Params>` estándar) y usar `emit.forEach()` en el bloc.

### 6.4 Suite de tests unitarios sin librerías de mocking

La suite cubre **95 tests** distribuidos en 19 archivos:

**Feature: daily_news — capa de datos**
- `ArticleModel.fromFirestore()` y `toJson()` (8 tests)

**Feature: daily_news — capa de dominio**
- `GetFirestoreArticlesUseCase` y `UploadArticleUseCase` (7 tests)
- `ToggleLikeUseCase`, `AddCommentUseCase`, `WatchCommentsUseCase`, `CheckLikeUseCase` (5 tests)

**Feature: daily_news — capa de presentación**
- `FirestoreArticlesBloc` y `UploadArticleBloc` (11 tests — incluye path imageUrl de IA)
- `filterArticles` (utilidad de búsqueda en feed) (6 tests)

**Feature: ai_article**
- `AiArticleRepositoryImpl` (5 tests)
- `LoremFlickrService` keyword sanitization (5 tests)
- `GenerateArticleUseCase` (3 tests)
- `GenerateArticleBloc` (5 tests)

**Feature: ai_chat**
- `AiChatService.parseSseLine` (parsing SSE, manejo de errores) (8 tests)
- `SendChatMessageUseCase` (2 tests)
- `AiChatBloc` (streaming de tokens, historial, manejo de errores) (11 tests)

**Feature: auth**
- `ChangePasswordUseCase` y `SignInWithGoogleUseCase` (4 tests)
- `AuthBloc` (sign-in, registro, cambio de contraseña, Google Sign-In) (8 tests)

**Configuración**
- `ThemeCubit` (6 tests)

### 6.5 Soporte completo para Flutter Web

El proyecto base no corría en web. Identifiqué y resolví tres incompatibilidades (`dart:io` en Floor/sqflite, `dart:io` para `HttpStatus`, y `cached_network_image` con API web eliminada) sin afectar el comportamiento nativo, usando `kIsWeb` para condicionar la inicialización de la base de datos local.

Además implementé un diseño responsive para que se use correctamente tanto en móviles como en desktops.

### 6.6 Carga con esqueleto animado

La pantalla principal muestra un esqueleto animado mientras se cargan los artículos de la API, en lugar de un spinner genérico. Esto mejora la percepción de velocidad y la experiencia de usuario.

### 6.7 SliverAppBar con imagen hero en detalle de artículo

La vista de detalle usa un `SliverAppBar` con la imagen del artículo como fondo y un gradiente de oscurecimiento en la parte inferior para que el título sea legible.

### 6.8 Firebase Auth con perfil de usuario editable

Se implementó autenticación completa con Firebase Auth (email/password + Google Sign-In). Más allá del login básico, se construyó una página de perfil donde el periodista puede:

- Editar su nombre de pantalla
- Subir una foto de perfil
- La foto se guarda inmediatamente tras seleccionarla, sin esperar al botón "Save", para evitar pérdida de datos si el usuario recarga la página

Las reglas de Firebase Storage se actualizaron para permitir solo al propietario escribir su avatar bajo `users/{uid}/avatar.jpg`, con validación de tipo MIME y tamaño máximo de 2 MB.

### 6.9 Fotos de autor en artículos del feed

Cuando un periodista publica un artículo, su `photoURL` se almacena en el documento de Firestore junto con el artículo. En el feed, la tarjeta de cada artículo muestra el avatar del autor en lugar de un placeholder con inicial. Esto crea coherencia visual entre el perfil del periodista y sus publicaciones.

### 6.10 Búsqueda local en Feed y Bookmarks

Se implementó una barra de búsqueda que filtra artículos en tiempo real por título, descripción o autor. La lógica de filtrado se extrajo a `article_filter.dart` (función pura) para ser reutilizable y testeable de forma aislada.

### 6.11 Toggle de bookmark en vista de detalle de artículo

El ícono de bookmark en la vista de detalle refleja el estado real del artículo (guardado/no guardado) y lo cambia al hacer tap.

### 6.12 Generación de artículos con IA (OpenRouter + loremflickr)

Los periodistas pueden generar un artículo completo desde una idea inicial. La arquitectura fue diseñada explícitamente para ser provider-agnostic:

```
AiTextProvider  ← OpenRouterService (default) | GeminiService (swap con 1 línea)
AiImageProvider ← LoremFlickrService (default) | cualquier servicio con API key
```

**Flujo completo:**
1. El periodista escribe una idea en el bottom sheet "Generate with AI"
2. OpenRouter genera título, descripción, contenido y keywords de imagen en JSON
3. `LoremFlickrService` construye una URL de loremflickr.com con los keywords para el thumbnail
4. Los campos se rellenan automáticamente en el formulario; el periodista puede editarlos antes de publicar
5. Al publicar, si la imagen es una URL, se guarda directamente en Firestore sin subir a Firebase Storage

**Decisión técnica destacada — CORS en Flutter Web:** `loremflickr.com` bloquea requests XHR desde el browser. La solución fue crear `AppNetworkImage`, un widget que en web usa `NetworkImage` con `WebHtmlElementStrategy.prefer` (elemento `<img>`, sin CORS) y en mobile usa `CachedNetworkImage`. Este widget reemplaza todos los thumbnails de la app.

**UX durante la espera:** El modelo de IA tarda hasta 60 segundos. Se implementaron frases rotativas cada 10 segundos con `AnimatedSwitcher` que informan al usuario del tiempo esperado y mantienen la sensación de actividad.

**Documentación para otros devs:** `docs/AI_GENERATION_SETUP.md` explica cómo obtener la API key, qué pasa si se omite, cómo hacer el swap a Gemini, y por qué se usa `--dart-define` en lugar de hardcodear la key.

### 6.13 Chat con IA en tiempo real (SSE streaming)

Agregué un cuarto tab de chat donde el periodista puede conversar con un modelo de lenguaje. La respuesta llega token por token vía Server-Sent Events: `AiChatService` usa Dio para consumir el stream, y `AiChatBloc` acumula los tokens con `emit.forEach()` actualizando la UI en cada fragmento. `ChatBubble` muestra un cursor parpadeante mientras la respuesta sigue llegando.

El historial completo de la conversación se incluye en cada request, así el modelo mantiene contexto entre turnos. Hay un botón "Clear" en el AppBar que solo aparece cuando el usuario está en ese tab. Los usuarios no autenticados ven un prompt de login en lugar del chat.

Un detalle que requirió atención: OpenRouter puede devolver un campo `error` dentro del JSON del stream en lugar de cortar la conexión. Implementé detección explícita de ese campo en el parser de SSE para propagarlo como error al bloc correctamente.

### 6.14 Likes, comentarios y propiedad de artículos

Los artículos publicados por periodistas tienen un sistema social: like toggle con contador visible en la tarjeta, y un hilo de comentarios accesible desde el detalle. Los likes se guardan en la subcolección `likes/{uid}` y el contador se actualiza atómicamente para evitar race conditions. Los comentarios se muestran en un `BottomSheet` con stream en tiempo real, igual que el feed principal.

Cada artículo guarda el `authorId` del periodista que lo publicó. Eso permite que solo el autor vea el botón de despublicar en su propio contenido, y que las reglas de Firestore lo hagan cumplir también en el backend.

### 6.15 Pull-to-refresh, share y badge

Ambos feeds soportan pull-to-refresh para recargar manualmente. En las tarjetas y en la vista de detalle hay un botón de compartir que usa `share_plus` con la Web Share API, lo que funciona en web, Android e iOS sin código específico por plataforma. El tab de Journalist muestra un badge con el número de artículos publicados, que se actualiza en tiempo real desde el mismo `FirestoreArticlesBloc` que ya carga el feed.

### 6.16 Branding: launcher icons y splash screen

La app tenía los íconos genéricos de Flutter. Generé launcher icons para todas las densidades de Android y para web usando `flutter_launcher_icons`, y una splash screen nativa en modo claro y oscuro con `flutter_native_splash`. El `web/manifest.json` también se actualizó con nombre, colores de tema y los íconos correctos. El logo queda disponible como asset `sn_logo.png` y lo uso en las pantallas de autenticación.

