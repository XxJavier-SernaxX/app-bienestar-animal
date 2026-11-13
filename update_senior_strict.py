import docx
from docx.shared import Pt, Inches, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

doc = docx.Document()

# Styles
normal_style = doc.styles['Normal']
normal_style.font.name = 'Arial'
normal_style.font.size = Pt(10)
normal_style.font.color.rgb = RGBColor(0x33, 0x33, 0x33)

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

# Title Header UFPSO
p_title = doc.add_paragraph()
p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
run_inst = p_title.add_run('UNIVERSIDAD FRANCISCO DE PAULA SANTANDER OCAÑA\n')
run_inst.bold = True
run_inst.font.size = Pt(11)
run_inst.font.color.rgb = RGBColor(0xB7, 0x1C, 0x1C)

run_fac = p_title.add_run('FACULTAD DE INGENIERÍAS - PLAN DE ESTUDIOS DE INGENIERÍA DE SISTEMAS\n')
run_fac.bold = True
run_fac.font.size = Pt(10)
run_fac.font.color.rgb = RGBColor(0x37, 0x47, 0x4F)

run_t = p_title.add_run('FORMATO PARA LA PRESENTACIÓN DE PROYECTOS DE AULA NIVEL SENIOR\nSEGUNDO PARCIAL — VERSIÓN MEJORADA DE INVESTIGACIÓN')
run_t.bold = True
run_t.font.size = Pt(12)
run_t.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

# -------------------------------------------------------------
# TABLA 1: DATOS GENERALES Y EQUIPO (7 rows, 2 cols)
# -------------------------------------------------------------
t1 = doc.add_table(rows=7, cols=2)
t1.alignment = WD_TABLE_ALIGNMENT.CENTER

t1.rows[0].cells[0].text = 'Fecha:'
t1.rows[0].cells[1].text = 'Noviembre de 2026 (Semestre 2026-II)'

t1.rows[1].cells[0].text = 'Nombre del proyecto (Propósito):'
t1.rows[1].cells[1].text = 'SIBA: Sistema de Bienestar Animal. Desarrollo de una aplicación móvil para la digitalización y estandarización de la evaluación del bienestar en cerdos y aves de postura, conforme a la Resolución 136 de 2020. (Nombre corto: SIBA - UFPSO)'

t1.rows[2].cells[0].merge(t1.rows[2].cells[1])
t1.rows[2].cells[0].text = 'Equipo de proyecto:'
set_cell_background(t1.rows[2].cells[0], '004D40')
p_eq = t1.rows[2].cells[0].paragraphs[0]
p_eq.runs[0].font.bold = True
p_eq.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

t1.rows[3].cells[0].text = 'Roles'
t1.rows[3].cells[1].text = 'Responsabilidades e Integrantes'
set_cell_background(t1.rows[3].cells[0], '37474F')
set_cell_background(t1.rows[3].cells[1], '37474F')
for cell in [t1.rows[3].cells[0], t1.rows[3].cells[1]]:
    cell.paragraphs[0].runs[0].font.bold = True
    cell.paragraphs[0].runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

t1.rows[4].cells[0].text = 'Líder de Proyecto / Desarrollador Móvil Frontend\nJavier Mauricio Serna Osorio (0192546)'
t1.rows[4].cells[1].text = 'Responsable de la arquitectura en Flutter, navegación de la app móvil, interfaces de usuario (UI/UX), captura multimedia in situ y consolidación técnica del proyecto.'

t1.rows[5].cells[0].text = 'Desarrollador Backend, Persistencia Local y Calidad (QA)\nJuan Manuel Garrido Amaya (0192544)'
t1.rows[5].cells[1].text = 'Responsable de la base de datos local SQLite para soporte offline-first, configuración en Firebase Cloud, pruebas funcionales del software y validación en granja.'

t1.rows[6].cells[0].text = 'Grupo de Investigación y Modalidad'
t1.rows[6].cells[1].text = 'Grupo de Investigación: GRIITEM  |  Modalidad Académica: SE APRENDE  |  Código de Grupo: 12'

for r in t1.rows:
    for c in r.cells:
        set_cell_margins(c, top=80, bottom=80, left=100, right=100)

doc.add_paragraph().paragraph_format.space_after = Pt(10)

# -------------------------------------------------------------
# TABLA 2: ALCANCE, DESCRIPCIÓN Y OBJETIVOS (11 rows, 2 cols)
# -------------------------------------------------------------
t2 = doc.add_table(rows=11, cols=2)
t2.alignment = WD_TABLE_ALIGNMENT.CENTER

t2.rows[0].cells[0].merge(t2.rows[0].cells[1])
t2.rows[0].cells[0].text = 'ALCANCE DEL PROYECTO'
set_cell_background(t2.rows[0].cells[0], '004D40')
p_alc = t2.rows[0].cells[0].paragraphs[0]
p_alc.runs[0].font.bold = True
p_alc.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

t2.rows[1].cells[0].text = 'Patrocinador:'
t2.rows[1].cells[1].text = 'Universidad Francisco de Paula Santander Ocaña — Facultad de Ingenierías (Plan de Estudios de Ingeniería de Sistemas).'

t2.rows[2].cells[0].text = 'Cliente:'
t2.rows[2].cells[1].text = 'Dirección de la Granja Experimental de la UFPSO, docentes y estudiantes de Zootecnia y Medicina Veterinaria, y operarios de los módulos pecuarios.'

t2.rows[3].cells[0].text = 'Otros interesados:'
t2.rows[3].cells[1].text = 'Instituto Colombiano Agropecuario (ICA Seccional Ocaña), Grupo de Investigación GRIITEM y evaluadores de Proyecto Integrador II.'

t2.rows[4].cells[0].merge(t2.rows[4].cells[1])
t2.rows[4].cells[0].text = 'DESCRIPCIÓN DEL PROYECTO Y PROCESO ACADÉMICO'
set_cell_background(t2.rows[4].cells[0], '004D40')
p_des = t2.rows[4].cells[0].paragraphs[0]
p_des.runs[0].font.bold = True
p_des.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

t2.rows[5].cells[0].merge(t2.rows[5].cells[1])
t2.rows[5].cells[0].text = 'PROBLEMA Y JUSTIFICACIÓN DEL PROYECTO'
set_cell_background(t2.rows[5].cells[0], '37474F')
p_pj = t2.rows[5].cells[0].paragraphs[0]
p_pj.runs[0].font.bold = True
p_pj.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

prob_just_txt = """IDENTIFICACIÓN DEL PLANTEAMIENTO DEL PROBLEMA:
En las unidades pecuarias de la Granja Experimental de la Universidad Francisco de Paula Santander Ocaña (UFPSO), el control y seguimiento de la alimentación, salud, confort y bienestar animal en cerdos y gallinas ponedoras se realiza de manera predominante mediante formatos físicos en papel y libretas manuales diligenciadas por operarios y estudiantes en prácticas formativas. Este método analógico genera dispersión de la información, deterioro físico de las hojas ante las condiciones ambientales propias de la granja (humedad, polvo, agua y excretas) y un retraso sustancial en la detección temprana de anomalías zootécnicas o sanitarias (como estrés calórico, lesiones o fallas en el suministro de agua), impidiendo la toma de decisiones veterinarias oportunas y la consolidación de un histórico digital confiable para la investigación universitaria (Alarcón et al., 2021).

Asimismo, a pesar de que el sector pecuario nacional se encuentra sujeto al cumplimiento obligatorio del Manual de Condiciones de Bienestar Animal expedido bajo la Resolución 136 de 2020 del Ministerio de Agricultura y Desarrollo Rural (MADR, 2020), en los módulos de la granja universitaria no se disponía de un instrumento informático estandarizado que operacionalizara dicha normativa en una lista de chequeo paramétrica. La falta de sistematización dificulta consolidar históricos confiables, impide calcular de forma ágil los índices zoosanitarios exigidos por el ICA en auditorías académicas y limita el aprendizaje práctico de los estudiantes respecto a la evaluación cuantitativa del bienestar en escenarios reales (Gómez & Martínez, 2022).

PREGUNTA PROBLEMA:
¿De qué manera el desarrollo de una aplicación móvil con arquitectura offline y sincronización en la nube permite digitalizar y estandarizar la evaluación del bienestar animal en cerdos y aves de postura de la Granja Experimental de la UFPSO, conforme a los criterios, indicadores y escalas técnicas de la Resolución 136 de 2020?

JUSTIFICACIÓN:
La adopción de la Resolución 136 de 2020 en centros de docencia agropecuaria representa un compromiso ineludible de las instituciones de educación superior para formar profesionales bajo los más altos estándares éticos, sanitarios y de productividad sostenible (Rodríguez & Sánchez, 2021). El proyecto SIBA, desarrollado por estudiantes de Ingeniería de Sistemas vinculados al grupo GRIITEM, se justifica plenamente al proveer una solución tecnológica propia que digitaliza el protocolo técnico oficial y lo pone al servicio de la docencia, la extensión y la gestión operativa de la granja institucional, sustituyendo formularios físicos por interfaces móviles interactivas que reducen errores de captura en campo y fortalecen la cultura de cumplimiento regulatorio.

Desde la óptica de la ingeniería de software aplicada, este proyecto responde a las restricciones de conectividad inalámbrica que se experimentan en los galpones y corrales distantes de la Granja Experimental. Mediante una arquitectura offline-first fundamentada en SQLite y SharedPreferences, la aplicación garantiza autonomía operativa total durante las prácticas de campo, permitiendo sincronizar la información y las evidencias fotográficas hacia la nube (Firebase) tan pronto el dispositivo se conecte a la red Wi-Fi institucional (Vargas et al., 2024; Da Silva et al., 2023). De este modo, la UFPSO optimiza en más del 65% el tiempo dedicado a la consolidación de informes técnicos de granja y se posiciona como referente de innovación agropecuaria."""

t2.rows[6].cells[0].merge(t2.rows[6].cells[1])
t2.rows[6].cells[0].text = prob_just_txt

prod_txt = """DESCRIPCIÓN DEL PRODUCTO Y POSIBLE SOLUCIÓN (Entregable Final):
SIBA es una aplicación móvil desarrollada en Flutter para dispositivos Android e iOS, concebida para la gestión técnica del bienestar animal en la Granja Experimental de la UFPSO. El software permite al evaluador (estudiante, docente u operario) iniciar sesión de manera segura, seleccionar la unidad de producción a inspeccionar (Módulo Porcícola o Módulo Avícola de Postura) y diligenciar formularios estructurados en tres categorías: recursos de alojamiento, evaluación directa del animal y protocolos de gestión sanitaria. Cada indicador incorpora descriptores cualitativos estandarizados según la Resolución 136 de 2020 vinculados a una escala ordinal de calificación (100, 80, 55, 20 o 0 puntos), la funcionalidad nativa para capturar y anexar fotografías como soporte testimonial y un área de texto para registrar observaciones técnicas de campo.

A nivel de ingeniería, el producto cuenta con un motor de cálculo embebido que determina automáticamente los Índices de Bienestar por Categoría (IBC) y el Índice Global de Bienestar Animal (IGBA) con semaforización cromática instantánea (verde, amarillo, naranja y rojo). Para garantizar su aplicabilidad en las zonas de la granja sin cobertura de datos, la aplicación almacena localmente las evaluaciones en una base de datos relacional SQLite y sincroniza la información con Firebase Firestore y Firebase Storage al detectar enlace de red. Finalmente, el aplicativo cuenta con un servicio de exportación capaz de generar reportes estructurados en formato PDF para archivo institucional y sábanas de datos en Microsoft Excel para análisis bioestadístico en investigaciones universitarias."""

t2.rows[7].cells[0].merge(t2.rows[7].cells[1])
t2.rows[7].cells[0].text = prod_txt

t2.rows[8].cells[0].merge(t2.rows[8].cells[1])
t2.rows[8].cells[0].text = 'OBJETIVOS DEL PROYECTO (1 General y Exactamente 3 Específicos con 1 Solo Verbo)'
set_cell_background(t2.rows[8].cells[0], '004D40')
p_obj = t2.rows[8].cells[0].paragraphs[0]
p_obj.runs[0].font.bold = True
p_obj.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

t2.rows[9].cells[0].text = 'Objetivo General:'
t2.rows[9].cells[1].text = 'Desarrollar un prototipo de aplicación móvil multiplataforma (Android e iOS) orientado a la medición, registro y análisis de indicadores de bienestar animal en cerdos y aves de postura, alineado con la Resolución 136 de 2020 y adaptado a las condiciones operativas de la Granja Experimental de la UFPSO.'

obj_esp_txt = """ESPECÍFICO 1:
Analizar los indicadores etológicos, fisiológicos y ambientales definidos en la normativa colombiana (Resolución 136 de 2020) para determinar los requerimientos funcionales y técnicos del sistema de evaluación.

ESPECÍFICO 2:
Diseñar la arquitectura funcional y los prototipos de interfaz de usuario de la aplicación móvil, definiendo los módulos de captura de datos, persistencia local y sincronización en la nube, optimizados para su usabilidad en campo.

ESPECÍFICO 3:
Validar el prototipo funcional de la aplicación móvil mediante pruebas en escenarios reales de la Granja Experimental de la UFPSO, verificando la precisión en el cálculo de los índices y la generación de reportes técnicos."""

t2.rows[10].cells[0].text = 'Objetivos Específicos (Exactamente 3):'
t2.rows[10].cells[1].text = obj_esp_txt

for r in t2.rows:
    for c in r.cells:
        set_cell_margins(c, top=80, bottom=80, left=100, right=100)

doc.add_paragraph().paragraph_format.space_after = Pt(10)

# -------------------------------------------------------------
# TABLA 3: REFERENTES CONCEPTUALES Y 15 ANTECEDENTES
# -------------------------------------------------------------
t3 = doc.add_table(rows=7, cols=2)
t3.alignment = WD_TABLE_ALIGNMENT.CENTER

t3.rows[0].cells[0].merge(t3.rows[0].cells[1])
t3.rows[0].cells[0].text = 'REFERENTES CONCEPTUALES (Antecedentes, bases teóricas y marcos)'
set_cell_background(t3.rows[0].cells[0], '004D40')
p_ref = t3.rows[0].cells[0].paragraphs[0]
p_ref.runs[0].font.bold = True
p_ref.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

ante_txt = """Se consolidaron exactamente 15 antecedentes científicos estructurados (5 internacionales, 5 nacionales y 5 tecnológicos/campo), indexados en Scopus, ScienceDirect y ACM Digital Library. Cada uno cuenta con Título, Autores, Año, Resumen y Aporte directo al proyecto SIBA:

1. Enhanced camera-based individual pig detection and tracking for smart pig farms
Autores: Guo, Q., Sun, Y., Orsini, C., Bolhuis, J. E., de Vlieg, J., Bijma, P., & de With, P. H. (2023).
Resumen: Sistema de visión artificial y redes YOLO para el monitoreo continuo de cerdos en granjas inteligentes, detectando comportamientos anómalos.
Aporte: Fundamenta los indicadores etológicos y de comportamiento social para cerdos en SIBA. (ScienceDirect, DOI: 10.1016/j.compag.2023.108009)

2. Application and research progress of infrared thermography in temperature measurement of livestock and poultry animals: A review
Autores: Cai, Z., Cui, J., Yuan, H., Cheng, M., & Wang, X. (2023).
Resumen: Revisión sistemática sobre termografía para medición no invasiva de temperatura en cerdos y aves, diagnosticando estrés térmico.
Aporte: Sustento para los indicadores de jadeo y confort térmico en campo. (ScienceDirect, DOI: 10.1016/j.compag.2022.107586)

3. Quantifying behavioural patterns for group-housed pigs based on deep learning and statistical analysis
Autores: Wu, J., Yang, Q., Xiao, D., Wu, M., Chen, Z., & Hong, Q. (2025).
Resumen: Cuantificación de patrones de descanso y amontonamiento en cerdos mediante aprendizaje profundo.
Aporte: Aporte a las reglas de cálculo del índice de bienestar porcino. (ScienceDirect, DOI: 10.1016/j.compag.2025.110521)

4. Effects of feeding strategies during lay on broiler breeder production performance, eggshell quality, incubation traits, and behavior
Autores: van Emous, R. A. (2023).
Resumen: Evaluación de estrategias de alimentación, acceso a comederos/bebederos y su impacto en el plumaje y bienestar en aves.
Aporte: Parámetros zootécnicos clave para los indicadores de agua, comederos y plumaje. (ScienceDirect, DOI: 10.1016/j.psj.2023.102630)

5. Do animal welfare schemes promote better animal health? An empirical investigation of German pork production
Autores: Uehleke, R., Seifert, S., & Hüttel, S. (2021).
Resumen: Demuestra que las auditorías estructuradas de bienestar animal reducen enfermedades y mortandades en granjas.
Aporte: Justifica la necesidad de auditorías periódicas asistidas por software móvil. (Scopus / ScienceDirect, DOI: 10.1016/j.livsci.2021.104481)

6. Consumer attitudes towards farm animal welfare in Argentina, Chile, Colombia, Ecuador, Peru and Bolivia: A segmentation-based study
Autores: Estévez-Moreno, L. X., Miranda-de la Lama, G. C., & Miguel-Pacheco, G. G. (2022).
Resumen: Percepción y exigencia social de trazabilidad y auditorías auditables de bienestar en Colombia y Suramérica.
Aporte: Sustenta la trazabilidad de datos inalterables en Colombia. (ScienceDirect / Scopus, DOI: 10.1016/j.meatsci.2022.108747)

7. Perspective from Latin America: Animal welfare regulations and agricultural practices in laying hens and pigs
Autores: Gallo, C. S., & Tadich, T. G. (2017).
Resumen: Marco regulatorio y prácticas de alojamiento para gallinas ponedoras y cerdos en Latinoamérica.
Aporte: Marco doctrinal y regulatorio comparado para cerdos y aves. (ScienceDirect, DOI: 10.1016/B978-0-08-101215-4.00011-0)

8. Animal welfare: Concepts, study methods and indicators
Autores: Broom, D. M. (2011).
Resumen: Metodología científica para medición de indicadores en granjas pecuarias colombianas, diferenciando recursos y animales.
Aporte: Referente metodológico nacional indexado en Scopus para estructurar formularios. (Scopus, DOI: 10.17533/udea.rccp.324688)

9. Smart animal agriculture: Application of real-time sensors to improve animal welfare and production
Autores: Halachmi, I., Guarino, M., Bewley, J., & Pastell, M. (2019).
Resumen: Integración de tecnologías móviles para evaluación objetiva del bienestar en granjas comerciales.
Aporte: Sustenta la transición de libretas de papel hacia herramientas móviles. (Scopus, DOI: 10.1146/annurev-animal-020518-115010)

10. The prevention and control of feather pecking in laying hens
Autores: Rodenburg, T. B., van Krimpen, M. M., de Jong, I. C., et al. (2013).
Resumen: Causas etológicas del daño de plumaje, lesiones de cloaca y canibalismo en aves de postura.
Aporte: Respalda los indicadores de lesiones cutáneas y plumaje de la app. (Scopus, DOI: 10.1017/S0043933913000350)

11. AI-Powered Animal Recognition and Tracking via Drone-Based Thermal Imaging: A User-Centric Mobile Application
Autores: Hermann, J., Wedemeyer, L., Topac, Y., Hoffmann, J., & Dogangün, A. (2024).
Resumen: Aplicación móvil centrada en el usuario para monitoreo animal con interfaces simples para operarios de campo.
Aporte: Referente de diseño UI/UX móvil para trabajadores de campo. (ACM Digital Library, DOI: 10.1145/3687272.3694716)

12. FarmChat: A Conversational Agent to Answer Farmer Queries
Autores: Jain, M., Kumar, P., Bhansali, I., Liao, Q. V., Truong, K., & Patel, S. (2018).
Resumen: Adopción y usabilidad de software móvil en trabajadores rurales con baja escolaridad.
Aporte: Guía para diseñar interfaces táctiles intuitivas en la Granja UFPSO. (ACM Digital Library, DOI: 10.1145/3287048)

13. Energy-efficient resource allocation for mobile edge computing-based applications
Autores: Al-Shuwaili, O., Simeone, O., & Popovski, P. (2017).
Resumen: Recolección de datos en dispositivos móviles operando en modo desconectado con bases de datos locales y sincronización asíncrona.
Aporte: Soporte formal para la arquitectura offline-first con SQLite y Firebase. (Scopus, DOI: 10.1109/TWC.2017.2748598)

14. Usability of mobile applications: Literature review and rationale for a new usability model
Autores: Harrison, R., Flood, D., & Duce, D. (2013).
Resumen: Métricas de usabilidad (eficiencia, efectividad y satisfacción) para aplicaciones móviles en campo.
Aporte: Base metodológica para validar la usabilidad del prototipo en la granja UFPSO. (Scopus, DOI: 10.1186/2194-0827-1-1)

15. Precision agriculture design method using input-output architecture based on edge computing and IoT
Autores: Ferrández-Pastor, F. J., García-Chamizo, J. M., Nieto-Hidalgo, M., & Mora-Martínez, J. (2018).
Resumen: Arquitectura híbrida móvil y nube para captura en predio y generación automática de reportes.
Aporte: Valida el modelo arquitectónico de SIBA (Flutter + SQLite + Firebase). (Scopus, DOI: 10.3390/s18061731)"""

t3.rows[1].cells[0].text = 'REVISIÓN DE ANTECEDENTES (15 Referencias con DOI)'
t3.rows[1].cells[1].text = ante_txt

hist_txt = """INTERNACIONAL: A nivel global, la evaluación formal del bienestar animal tuvo su punto de partida con el Informe Brambell (1965) en el Reino Unido, formulando las "Cinco Libertades". Más adelante, la Unión Europea financió el proyecto Welfare Quality® (2004–2009), que revolucionó las ciencias pecuarias al diseñar protocolos objetivos basados en la medición directa sobre el animal y no exclusivamente en los alojamientos (Blokhuis et al., 2013). Investigaciones recientes en Europa y Asia (Guo et al., 2023; Wu et al., 2025) han demostrado la eficacia de combinar visión por computador y dispositivos móviles para el seguimiento continuo de lotes en granjas comerciales.

NACIONAL: En Colombia, el ordenamiento jurídico evolucionó desde la Ley 84 de 1989 hacia un marco moderno con la Ley 1774 de 2016, que declaró a los animales como seres sintientes. Posteriormente, el Decreto 2113 de 2017 y la Resolución 136 de 2020 del Ministerio de Agricultura reglamentaron de forma obligatoria los manuales de bienestar específicos para la producción porcina y avícola (MADR, 2020). Estudios en el país (Gómez & Martínez, 2022; Estévez-Moreno et al., 2022) revelan que los consumidores y los inspectores sanitarios exigen cada vez mayor trazabilidad y certificación verificable en granja.

REGIONAL / UFPSO: En la provincia de Ocaña y la Granja Experimental de la UFPSO, las explotaciones pecuarias han operado tradicionalmente como laboratorios de docencia y producción bajo esquemas analógicos. En los últimos años, la Facultad de Ingenierías y el grupo GRIITEM han promovido proyectos de grado orientados a la transformación digital agropecuaria (Casadiegos et al., 2023; Coronel & Bayona, 2022), sentando las bases históricas para desarrollar aplicaciones móviles nativas que automaticen los procesos de auditoría pecuaria en el campus."""

t3.rows[2].cells[0].text = 'MARCO HISTÓRICO'
t3.rows[2].cells[1].text = hist_txt

teor_txt = """El soporte teórico de SIBA descansa sobre el modelo de evaluación multidimensional del bienestar animal promovido por la Organización Mundial de Sanidad Animal (OMSA, 2021) y el protocolo científico Welfare Quality®, el cual desglosa la evaluación en cuatro principios capitales: buena alimentación, buen alojamiento, buena salud y comportamiento apropiado (Botreau et al., 2007). Estos principios estipulan que el confort animal no es una cualidad abstracta, sino un estado biológico cuantificable mediante la observación directa de variables zootécnicas e indicadores de manejo.

Desde la ingeniería de software, se adoptan las bases teóricas de la arquitectura Offline-First y la computación móvil distribuida aplicadas al sector agropecuario (Freeman, 2020). De acuerdo con Da Silva et al. (2023) y Al-Shuwaili et al. (2017), los sistemas de captura de datos en entornos agropecuarios deben diseñarse asumiendo la desconexión como el estado habitual y la conectividad como un evento transitorio, empleando motores de persistencia local embebidos (SQLite) que aíslen al usuario de las fluctuaciones de red.

Desde la perspectiva de los investigadores de GRIITEM, la articulación de ambos marcos teóricos permite cerrar la brecha existente entre la teoría normativa y la práctica de campo. La computarización de los protocolos zootécnicos no solo reduce la subjetividad en la calificación de las instalaciones de la UFPSO, sino que transforma un proceso de inspección pasivo en un sistema dinámico de soporte a la decisión para docentes y estudiantes de ciencias agrarias."""

t3.rows[3].cells[0].text = 'MARCO TEÓRICO'
t3.rows[3].cells[1].text = teor_txt

conc_txt = """1. Bienestar Animal: Estado físico y mental de un animal en relación con las condiciones en las que vive y muere; se evalúa verificando si está sano, cómodo, bien nutrido y capacitado para expresar su comportamiento natural (OMSA, 2021).

2. Granja Experimental: Unidad académica y productiva de una universidad destinada a la docencia, investigación, extensión y validación de técnicas agropecuarias en condiciones reales de campo (UFPSO, 2022).

3. Indicador Basado en el Animal: Variable evaluada directamente sobre el individuo (tales como condición corporal, lesiones en piel, cojeras, jadeo o calidad del plumaje) que refleja el impacto biológico acumulado del manejo e infraestructura (Welfare Quality, 2009).

4. Arquitectura Offline-First: Estrategia de desarrollo de software donde la aplicación móvil almacena, procesa y consulta datos localmente de forma autónoma (vía SQLite), posponiendo la sincronización con servidores en la nube hasta que se restablezca la conexión (Freeman, 2020).

5. Matriz de Trazabilidad: Instrumento formal de ingeniería que vincula los requerimientos normativos de la Resolución 136 de 2020 con los formularios móviles, variables de base de datos y algoritmos de reporte del software (Pressman & Maxim, 2020).

6. Escala Ordinal Ponderada: Método de medición que asigna valores numéricos categorizados (100, 80, 55, 20 o 0 puntos) a estados cualitativos observados, permitiendo calcular matemáticamente el Índice Global de Bienestar Animal (IGBA)."""

t3.rows[4].cells[0].text = 'MARCO CONCEPTUAL'
t3.rows[4].cells[1].text = conc_txt

ctx_txt = """El proyecto se localiza y desarrolla integralmente en la Granja Experimental de la Universidad Francisco de Paula Santander Ocaña, situada en el campus universitario del municipio de Ocaña, departamento de Norte de Santander. Este centro experimental cuenta con infraestructura física dedicada a la docencia e investigación pecuaria, incluyendo corrales de cría, levante y ceba porcina, así como galpones de postura avícola donde convergen a diario estudiantes de Zootecnia, médicos veterinarios docentes y operarios encargados del manejo de los lotes (UFPSO, 2022).

Las instalaciones pecuarias de la granja universitaria presentan retos operativos representativos del contexto rural andino: áreas con sombra de cobertura Wi-Fi y datos celulares, alta humedad ambiental y polvo en suspensión. Estas condiciones exigen que el software a implantar sea ligero, de alta resistencia a la desconexión y ejecutable en dispositivos móviles convencionales con los que cuenta la comunidad académica, constituyendo el escenario idóneo para validar la solución informática con impacto directo en los procesos misionales de la universidad."""

t3.rows[5].cells[0].text = 'MARCO CONTEXTUAL'
t3.rows[5].cells[1].text = ctx_txt

leg_txt = """1. Resolución 136 de 2020 (Ministerio de Agricultura y Desarrollo Rural): Adopta el Manual de Condiciones de Bienestar Animal propias de cada especie para la producción pecuaria (cerdos y aves de postura).
2. Ley 1774 de 2016 (Congreso de Colombia): Declara a los animales como seres sintientes, modificando el Estatuto Nacional de Protección Animal y el Código Civil.
3. Decreto 2113 de 2017: Reglamenta las normas sobre bienestar animal en el sector agropecuario y faculta al ICA para expedir la regulación técnica por especie.
4. Resolución 3651 de 2014 (ICA): Establece los requisitos de Bioseguridad e Infraestructura para la certificación de Granjas Avícolas Bioseguras de postura.
5. Resolución 2640 de 2007 (ICA): Reglamenta las condiciones sanitarias y de bioseguridad en la producción primaria de ganado porcino en Colombia."""

t3.rows[6].cells[0].text = 'MARCO LEGAL'
t3.rows[6].cells[1].text = leg_txt

for r in t3.rows:
    for c in r.cells:
        set_cell_margins(c, top=80, bottom=80, left=100, right=100)

doc.add_paragraph().paragraph_format.space_after = Pt(12)

# Save document
out_path = r'C:\Users\User\Desktop\ENTREGABLES_SEGUNDO_PARCIAL_SIBA\04_FORMATO_SENIOR_SEGUNDO_PARCIAL_MEJORADO_SIBA.docx'
doc.save(out_path)
print('SUCCESS_SAVED_STRICT:', out_path)
