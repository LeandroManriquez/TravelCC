# 🚛 TRAVEL CC — La Ruta que Aprende

> **Propuesta de Valor:** Para conductores y empresas de transporte pesado que necesitan rutas seguras y operativamente viables, **TRAVEL CC** entrega navegación adaptada y monitoreo en tiempo real, incorporando progresivamente la experiencia colectiva de los conductores.

---

## 👥 Integrantes del Equipo

| Nombre y Apellido | Usuario GitHub | Rol Principal |
| :--- | :--- | :--- |
| **Leandro Manríquez** | [@LeandroManriquez](https://github.com/LeandroManriquez) | Coordinación 
| **Ignacia Quiroz** | [@igna-Quiroz](https://github.com/igna-Quiroz) | Documentación 

---

## 📚 Información Académica
* **Asignatura:** Arquitectura de Desarrollo (Móvil y Web)
* **Código:** INGT1003
* **Semestre:** 2026-2

---

## 🎯 El Problema
Los mapas convencionales están pensados para vehículos livianos y no comprenden las restricciones físicas ni operativas de un camión de transporte pesado:
* **Restricciones físicas y dinámicas:** Altura, peso, ancho, longitud, horarios permitidos y estado de las vías.
* **Impacto vial en Chile:** 73.081 siniestros de tránsito en 2025 y 2.934 colisiones con participación de camiones en 2024 (Conaset)
* **Límites normativos:** Alturas desde 4,2 m requieren permisos especiales de la Dirección de Vialidad.

---

## 💡 Solución: Tres Capacidades en un Solo Ecosistema

1. 🗺️ **Navegación Heavy:** Cálculo de rutas considerando las dimensiones del vehículo y restricciones de red vial.
2. 📡 **Fleet Tracking:** Monitoreo en tiempo real de ubicación, velocidad, paradas y desviaciones para jefes de flota.
3. 🧠 **Mapa que Aprende (Crowdsourcing):** Detección automática de desviaciones y patrones de tráfico para alimentar una base geoespacial viva.

---

## 🏗️ Arquitectura del Sistema (teoria)

```text
[ App Conductor ] ──(GPS / Eventos)──> [ API REST / Servidor ]
                                              │
                                              ▼
[ Crowdsourcing ] <──(Anomalías/Score)── [ Lógica de Negocio ]
                                              │
                                              ▼
                                    [ BD PostgreSQL + PostGIS ]# 🚛 TRAVEL CC — La Ruta que Aprende

---

## 🤖 Declaración de Uso de Inteligencia Artificial

En conformidad con las normas de la asignatura, se declara el uso de herramientas de Inteligencia Artificial Generativa bajo la siguiente trazabilidad:

* **Herramienta utilizada:** Google Gemini.
* **Componente / Entregable:** Maquetación y estructura del sitio web interactivo de presentación (`index.html`, `styles.css`, `script.js`).
* **Instrucción / Prompt principal:** *"Diseña y genera la página web interactiva para la presentación del proyecto TRAVEL CC tomando como base nuestra idea general, problema, solución y arquitectura"*.
* **Aporte Humano y Verificación:**
  * **Investigación previa:** El equipo realizó el levantamiento del problema, las cifras oficiales (CONASET y Dirección de Vialidad), la promesa de valor y el diseño de la arquitectura del sistema.
  * **Validación técnica:** El equipo revisó, probó y ajustó el código HTML/CSS/JS generado para asegurar su correcto despliegue, navegabilidad y fidelidad con los requisitos técnicos exigidos en la pauta.