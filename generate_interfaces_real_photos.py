# -*- coding: utf-8 -*-
"""
Genera el Documento 02: FORMATO DISEÑO DE INTERFACES DE USUARIO (UI/UX)
incrustando las 10 capturas de pantalla REALES de la aplicación móvil SIBA.
Mantiene la portada institucional oficial de Análisis y Diseño de Sistemas,
tipografía uniforme Arial y color sobrio profesional.
"""

import os
import docx
from docx import Document
from docx.shared import Pt, Inches, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

OUT_DIR = r"C:\Users\User\Desktop\ENTREGABLES_SEGUNDO_PARCIAL_SIBA"
SC_DIR = r"c:\Users\User\Desktop\SIBa\app-bienestar-animal-main\screenshots_app"
OUT_PATH = os.path.join(OUT_DIR, "02_FORMATO_DISENO_DE_INTERFACES_UI_UX_SIBA.docx")

FONT_NAME = "Arial"
COLOR_PRIMARY = RGBColor(0x1A, 0x1A, 0x1A)
COLOR_MUTED = RGBColor(0x55, 0x55, 0x55)

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=140, right=140):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def set_table_borders(table, color="D0D0D0", sz="4", val="single"):
    tblPr = table._tbl.tblPr
    borders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        f'  <w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'  <w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'  <w:left w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'  <w:right w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'  <w:insideH w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'  <w:insideV w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'</w:tblBorders>'
    )
    tblPr.append(borders)

def add_official_cover(doc):
    doc.add_paragraph()
    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.line_spacing = 1.15
    p_title.paragraph_format.space_after = Pt(4)
    run_t = p_title.add_run(
        "Desarrollo de una aplicación móvil para la digitalización y estandarización\n"
        "de la evaluación del bienestar en cerdos y aves de postura,\n"
        "conforme a la Resolución 136 de 2020\n\n"
        "SIBA: Sistema de Bienestar Animal"
    )
    run_t.font.name = FONT_NAME
    run_t.font.size = Pt(13)
    run_t.bold = True
    run_t.font.color.rgb = COLOR_PRIMARY

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_before = Pt(4)
    run_sub = p_sub.add_run("DOCUMENTO ENTREGABLE: DISEÑO DE INTERFACES DE USUARIO (UI/UX)")
    run_sub.font.name = FONT_NAME
    run_sub.font.size = Pt(11)
    run_sub.bold = True
    run_sub.font.color.rgb = COLOR_MUTED

    for _ in range(5):
        doc.add_paragraph()

    p_team_lbl = doc.add_paragraph()
    p_team_lbl.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_tl = p_team_lbl.add_run("Integrantes:")
    r_tl.font.name = FONT_NAME
    r_tl.font.size = Pt(11)
    r_tl.bold = True
    r_tl.font.color.rgb = COLOR_PRIMARY

    p_team = doc.add_paragraph()
    p_team.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_team.paragraph_format.line_spacing = 1.15
    r_t1 = p_team.add_run("Javier Mauricio Serna Osorio — Código: 0192546\nJuan Manuel Garrido Amaya — Código: 0192544")
    r_t1.font.name = FONT_NAME
    r_t1.font.size = Pt(11)
    r_t1.font.color.rgb = COLOR_PRIMARY

    for _ in range(6):
        doc.add_paragraph()

    p_doc_lbl = doc.add_paragraph()
    p_doc_lbl.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_dl = p_doc_lbl.add_run("Docente:")
    r_dl.font.name = FONT_NAME
    r_dl.font.size = Pt(11)
    r_dl.bold = True
    r_dl.font.color.rgb = COLOR_PRIMARY

    p_doc = doc.add_paragraph()
    p_doc.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_d1 = p_doc.add_run("Mgtr. Yegny karina Amaya Torrado")
    r_d1.font.name = FONT_NAME
    r_d1.font.size = Pt(11)
    r_d1.font.color.rgb = COLOR_PRIMARY

    for _ in range(7):
        doc.add_paragraph()

    p_inst = doc.add_paragraph()
    p_inst.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_inst.paragraph_format.line_spacing = 1.15
    r_inst = p_inst.add_run(
        "Facultad de Ingenierías\n"
        "Ingeniería de Sistemas\n"
        "Analisis y diseño de Sistemas\n"
        "Ocaña, Norte de Santander, Colombia\n"
        "2026"
    )
    r_inst.font.name = FONT_NAME
    r_inst.font.size = Pt(11)
    r_inst.font.color.rgb = COLOR_PRIMARY

    doc.add_page_break()

def generate_doc_02():
    doc = Document()
    
    for sec in doc.sections:
        sec.top_margin = Inches(1)
        sec.bottom_margin = Inches(1)
        sec.left_margin = Inches(1.0)
        sec.right_margin = Inches(1.0)

    normal = doc.styles['Normal']
    normal.font.name = FONT_NAME
    normal.font.size = Pt(10)
    normal.font.color.rgb = COLOR_PRIMARY

    # Portada oficial bien espaciada
    add_official_cover(doc)

    # Encabezado institucional oficial
    p_head = doc.add_paragraph()
    p_head.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r1 = p_head.add_run("FACULTAD DE INGENIERÍAS\nPLAN DE ESTUDIOS DE INGENIERÍA DE SISTEMAS\n")
    r1.bold = True
    r1.font.size = Pt(11)
    r1.font.color.rgb = COLOR_PRIMARY

    r2 = p_head.add_run("FORMATO DISEÑO DE INTERFACES DE USUARIO\n")
    r2.bold = True
    r2.font.size = Pt(12)
    r2.font.color.rgb = COLOR_PRIMARY

    # Cuadro de objetivo del template original
    tbl_obj = doc.add_table(rows=1, cols=1)
    tbl_obj.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell_obj = tbl_obj.cell(0, 0)
    set_cell_background(cell_obj, "F5F5F5")
    set_cell_margins(cell_obj, top=140, bottom=140, left=180, right=180)
    set_table_borders(tbl_obj, color="BDBDBD", sz="6")

    p_box = cell_obj.paragraphs[0]
    p_box.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    r_ob1 = p_box.add_run("Objetivo: ")
    r_ob1.bold = True
    r_ob1.font.size = Pt(10)
    r_ob1.font.color.rgb = COLOR_PRIMARY

    r_ob2 = p_box.add_run(
        "Definir y desarrollar una interfaz de usuario intuitiva, funcional y atractiva, que facilite la "
        "interacción del usuario con el sistema, garantizando una experiencia de uso eficiente, accesible y "
        "centrada en las necesidades del usuario final en condiciones operativas de campo."
    )
    r_ob2.font.size = Pt(10)
    r_ob2.font.color.rgb = COLOR_PRIMARY

    doc.add_paragraph()
    p_tc = doc.add_paragraph()
    r_tc = p_tc.add_run("Tener en cuenta:")
    r_tc.bold = True
    r_tc.font.size = Pt(11)

    p_tcd = doc.add_paragraph()
    p_tcd.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    p_tcd.add_run(
        "El formato debe contener las pantallas principales del sistema, plataforma, y App móvil con una "
        "breve descripción donde se explique claramente la función que cumple cada vista dentro del flujo de evaluación, "
        "acompañadas de las evidencias fotográficas reales de la aplicación móvil en ejecución sobre dispositivo Android, "
        "los requisitos funcionales cubiertos y los criterios de usabilidad adaptados al trabajo en granja."
    )

    doc.add_paragraph()

    # Información de las 10 pantallas reales
    screens_meta = [
        {
            "img": "screenshot_01.jpg",
            "num": "01",
            "name": "Pantalla de Inicio / Bienvenida y Registro Local del Evaluador",
            "rf": "RF05, RF14",
            "actor": "U002 (Evaluador Técnico / MVZ), U003 (Operario de Granja)",
            "func": (
                "Permite al usuario identificarse en el aplicativo antes de iniciar las evaluaciones de campo. "
                "Incluye campo para el nombre del evaluador, selector de fecha opcional y almacenamiento seguro "
                "local ('Tu información se guarda solo en este dispositivo'), garantizando la operación autónoma "
                "offline sin requerir conexión a internet previa en los corrales."
            ),
            "components": (
                "• Barra de título superior 'SIBA - Bienestar Animal' con color esmeralda corporativo (#00897B).\n"
                "• Tarjeta central elevada con logo oficial SIBA (porcino y ave).\n"
                "• Campo de texto interactivo 'Tu nombre'.\n"
                "• Selector de calendario 'Selecciona una fecha (opcional)'.\n"
                "• Botón de acción principal 'Continuar' con retroalimentación háptica.\n"
                "• Mensaje de seguridad de datos locales SQLite."
            ),
            "usability": (
                "Contraste visual óptimo sobre fondo verde menta suave; botón ancho de altura 48 dp accesible "
                "con una sola mano o guantes de bioseguridad en granja."
            )
        },
        {
            "img": "screenshot_02.jpg",
            "num": "02",
            "name": "Pantalla de Selección de Especie Productiva",
            "rf": "RF06, RF02",
            "actor": "U002 (Evaluador Técnico), U003 (Operario de Granja)",
            "func": (
                "Permite al evaluador seleccionar la especie animal a valorar según la Resolución 136 de 2020. "
                "Muestra en el encabezado los datos de la sesión (Nombre del evaluador y Fecha actual). "
                "Al seleccionar Porcinos o Aves de Postura, el sistema carga en memoria la plantilla zootécnica correspondiente."
            ),
            "components": (
                "• Barra superior con flecha de retorno y título 'Elegir especie'.\n"
                "• Banner informativo superior: 'Evaluador: Javier' | 'Fecha: 2026-11-05'.\n"
                "• Tarjeta seleccionable 'Porcinos' con icono verde representativo.\n"
                "• Tarjeta seleccionable 'Aves de Postura' con icono naranja de nido/huevo.\n"
                "• Animación de pulsación (InkWell) que confirma la selección."
            ),
            "usability": (
                "Tarjetas de gran tamaño con iconografía cromática diferenciada por especie para evitar confusiones "
                "al transitar entre diferentes áreas de la Granja Experimental."
            )
        },
        {
            "img": "screenshot_03.jpg",
            "num": "03",
            "name": "Módulo Principal de Especie (Bienestar Porcino)",
            "rf": "RF06, RF07",
            "actor": "U002 (Evaluador Técnico), U003 (Operario de Granja)",
            "func": (
                "Pantalla de bienvenida y contextualización del módulo de Bienestar Porcino. Presenta una imagen real "
                "de cerdos en corral y guía al usuario para abrir el menú de navegación lateral mediante el botón "
                "hamburguesa (☰), a fin de explorar los indicadores técnicos normativos."
            ),
            "components": (
                "• AppBar superior verde con icono de menú (☰) y título 'Bienestar Porcino'.\n"
                "• Imagen fotográfica contextual de porcinos en condiciones de granja.\n"
                "• Título de bienvenida destacado 'Bienvenido al módulo de Bienestar Porcino 🐷'.\n"
                "• Texto instructivo claro: 'Usa el menú ☰ para explorar la evaluación del bienestar animal.'\n"
                "• Soporte gestual para abrir el menú deslizando desde el borde izquierdo."
            ),
            "usability": (
                "Diseño minimalista que reduce la sobrecarga cognitiva del evaluador y establece claramente "
                "el punto de partida de la inspección zootécnica."
            )
        },
        {
            "img": "screenshot_04.jpg",
            "num": "04",
            "name": "Menú Lateral de Navegación (Drawer) y Categorías ICA",
            "rf": "RF07, RF17",
            "actor": "U001 (Admin), U002 (Evaluador), U003 (Operario)",
            "func": (
                "Menú de navegación estructurado que organiza las categorías normativas de bienestar según los manuales "
                "oficiales del ICA y la Resolución 136 de 2020. Permite alternar entre los grupos de indicadores "
                "(Recursos, Animal, Gestión), consultar los resultados y acceder a la documentación normativa."
            ),
            "components": (
                "• Encabezado de Drawer con marca 'SIBA - Bienestar Animal' y subtítulo 'Metodología ICA · Versión 1.0'.\n"
                "• Ítem 'Recursos' con icono de maletín verde (alojamiento, agua, comederos, ambiente).\n"
                "• Ítem 'Animal' con icono de huella naranja (condición corporal, salud, comportamiento).\n"
                "• Ítem 'Gestión' con icono de engranaje (planes sanitarios, bioseguridad, registros).\n"
                "• Ítem 'Resultados' con icono de gráficos de barras.\n"
                "• Ítem 'Documentos ICA' con icono de PDF para consulta legal in situ.\n"
                "• Ítem 'Ver resultados guardados' para auditoría del historial local."
            ),
            "usability": (
                "Jerarquía visual clara con iconografía codificada por color; acceso rápido a cualquier sección del "
                "sistema en menos de dos toques de pantalla."
            )
        },
        {
            "img": "screenshot_05.jpg",
            "num": "05",
            "name": "Lista de Indicadores Normativos de la Categoría Recursos (Avance Inicial)",
            "rf": "RF07, RF17",
            "actor": "U002 (Evaluador Técnico), U003 (Operario de Granja)",
            "func": (
                "Presenta el listado estructurado de indicadores de la categoría 'Recursos' (infraestructura y ambiente). "
                "Muestra visualmente qué indicadores ya han sido evaluados (tachados y con check verde de verificación) "
                "y cuáles permanecen pendientes con selector circular y flecha de acceso."
            ),
            "components": (
                "• AppBar verde con botón de retroceso y título de categoría 'Recursos'.\n"
                "• Tarjetas individuales por indicador con esquinas redondeadas y sombreado suave.\n"
                "• Indicadores completados: 'Estado de los Comederos' y 'Acceso al Agua (flujo)' con badge verde '✓'.\n"
                "• Indicadores pendientes: 'Estado de limpieza de los bebederos', 'Altura de los bebederos', "
                "'Número de bebederos por animal', 'Protección ante condiciones ambientales', 'Ventilación', 'Iluminación'.\n"
                "• Flechas de navegación (chevron derecho) que conducen al formulario de calificación individual."
            ),
            "usability": (
                "La diferenciación tachada de ítems evaluados ofrece retroalimentación inmediata del estado de avance, "
                "evitando que el operario omita parámetros críticos durante el recorrido por galpones."
            )
        },
        {
            "img": "screenshot_06.jpg",
            "num": "06",
            "name": "Formulario de Calificación Ordinal, Evidencia Fotográfica y Notas",
            "rf": "RF08, RF09, RF10",
            "actor": "U002 (Evaluador Técnico), U003 (Operario de Granja)",
            "func": (
                "Vista de captura in situ para un indicador específico ('Estado de limpieza de los bebederos'). "
                "Permite seleccionar la calificación en la escala ordinal oficial de la Metodología ICA (100, 55, 20, 0 puntos) "
                "con descriptores zootécnicos claros, capturar evidencia fotográfica con la cámara y registrar observaciones técnicas."
            ),
            "components": (
                "• Encabezado con título del indicador evaluado.\n"
                "• Sección 'Selecciona una calificación' con radio buttons accesibles:\n"
                "  - '100 puntos — Todos limpios.'\n"
                "  - '55 puntos — Hasta el 25% sucios.'\n"
                "  - '20 puntos — Más del 25% y hasta el 50% sucios.'\n"
                "  - '0 puntos — Más del 50% sucios.'\n"
                "• Sección 'Evidencia fotográfica' con contenedor visual, icono de cámara y botón 'Tomar foto'.\n"
                "• Sección 'Observaciones (opcional)' con campo multilínea para notas técnicas del lote."
            ),
            "usability": (
                "Textos de opciones totalmente legibles y autosuficientes que eliminan la necesidad de memorizar tablas "
                "normativas; botón de cámara directo para registro instantáneo de evidencias visuales."
            )
        },
        {
            "img": "screenshot_07.jpg",
            "num": "07",
            "name": "Monitoreo del Progreso de Diligenciamiento en Campo",
            "rf": "RF07, RF17",
            "actor": "U002 (Evaluador Técnico), U003 (Operario de Granja)",
            "func": (
                "Muestra la actualización dinámica de la lista de verificación conforme el operario avanza en la inspección. "
                "Refleja la persistencia inmediata en la base de datos SQLite local de cada calificación y foto almacenada."
            ),
            "components": (
                "• Actualización del estado del indicador 'Estado de limpieza de los bebederos' tras ser calificado.\n"
                "• Indicadores pendientes restantes organizados por orden ergonómico de inspección en el corral.\n"
                "• Scroll suave optimizado para interacción con una sola mano en movimiento."
            ),
            "usability": (
                "Confirmación visual instantánea que refuerza la confianza del evaluador en la persistencia "
                "de los datos capturados sin temor a pérdidas por cierre de la aplicación."
            )
        },
        {
            "img": "screenshot_08.jpg",
            "num": "08",
            "name": "Matriz Completa de Indicadores Ambientales y de Alojamiento",
            "rf": "RF07, RF15",
            "actor": "U002 (Evaluador Técnico), U003 (Operario de Granja)",
            "func": (
                "Permite revisar el conjunto completo de variables de infraestructura y ambiente que exige la normativa: "
                "bebederos, comederos, ventilación, iluminación, protección climática y superficie de descanso."
            ),
            "components": (
                "• Listado completo con ítems de 'Superficie de descanso', 'Ventilación' e 'Iluminación'.\n"
                "• Renderizado eficiente con ListView.builder de Flutter para fluidez a 60 FPS.\n"
                "• Separadores limpios entre tarjetas que maximizan la legibilidad."
            ),
            "usability": (
                "Estructura uniforme que facilita la lectura rápida durante la auditoría zootécnica."
            )
        },
        {
            "img": "screenshot_09.jpg",
            "num": "09",
            "name": "Pantalla de Resultados Finales, Índices de Bienestar y Evidencias",
            "rf": "RF11, RF12, RF13",
            "actor": "U002 (Evaluador Técnico), U004 (Directivo / Inspector ICA)",
            "func": (
                "Consolida y procesa automáticamente las calificaciones de todos los indicadores evaluados. "
                "Calcula el promedio general ponderado, clasifica el nivel de bienestar animal alcanzado "
                "('52.5 puntos — Regular') y despliega el resumen de cada variable con su puntaje y su "
                "evidencia fotográfica adjunta en miniatura."
            ),
            "components": (
                "• AppBar verde con flecha de retorno y título 'Resultados finales'.\n"
                "• Tarjeta destacada de Promedio General con fondo cálido y texto resaltado: '52.5 puntos — Regular'.\n"
                "• Tarjetas individuales por indicador evaluado con foto adjunta en miniatura y puntaje oficial:\n"
                "  - 'Acceso al Agua (flujo)' — Puntaje: 55 (con foto de bebedero).\n"
                "  - 'Estado de los Comederos' — Puntaje: 0 (con foto de comedero sucio).\n"
                "  - 'Condición Corporal' — Puntaje: 100.\n"
                "  - 'Heces sobre el cuerpo' — Puntaje: 55."
            ),
            "usability": (
                "Visualización inmediata del dictamen técnico con evidencias fotográficas directas, lo que "
                "facilita la toma de decisiones correctivas inmediatas en la granja y respalda las auditorías."
            )
        },
        {
            "img": "screenshot_10.jpg",
            "num": "10",
            "name": "Modal de Consulta Normativa y Documentos Oficiales ICA",
            "rf": "RF02, RF07",
            "actor": "U001 (Admin), U002 (Evaluador), U004 (Inspector ICA)",
            "func": (
                "Diálogo modal interactivo accesible desde cualquier sección de la app. Brinda acceso directo a los "
                "documentos regulatorios oficiales almacenados localmente en formato PDF: la 'Metodología EBA Porcinos 3.0' "
                "y la 'Resolución ICA 0254 de 2024', permitiendo contrastar criterios técnicos ante cualquier duda en campo."
            ),
            "components": (
                "• Diálogo flotante estilizado con título 'Documentos ICA'.\n"
                "• Enlace con icono de PDF rojo: 'Metodología EBA Porcinos 3.0'.\n"
                "• Enlace con icono de PDF rojo: 'Resolución ICA 0254 de 2024'.\n"
                "• Botón de acción 'Cerrar' para regresar a la evaluación en curso."
            ),
            "usability": (
                "Garantiza el respaldo técnico y normativo directo al alcance de un toque, fortaleciendo el rigor "
                "científico de las evaluaciones realizadas por docentes y estudiantes en la UFPSO."
            )
        }
    ]

    p_sec = doc.add_paragraph()
    r_s = p_sec.add_run("Catálogo Detallado de Pantallas del Prototipo SIBA (Evidencias de la App Real)")
    r_s.bold = True
    r_s.font.size = Pt(11.5)
    doc.add_paragraph()

    for sc in screens_meta:
        img_path = os.path.join(SC_DIR, sc['img'])
        
        # Título de la pantalla
        p_t = doc.add_paragraph()
        p_t.paragraph_format.space_before = Pt(8)
        p_t.paragraph_format.space_after = Pt(4)
        r_num = p_t.add_run(f"Pantalla {sc['num']}: ")
        r_num.bold = True
        r_num.font.size = Pt(11)
        r_name = p_t.add_run(sc['name'])
        r_name.bold = True
        r_name.font.size = Pt(11)

        # Tabla de 2 columnas: Izquierda Imagen Real (2.2 in), Derecha Metadatos y Descripción (4.3 in)
        tbl = doc.add_table(rows=1, cols=2)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        set_table_borders(tbl, color="D0D0D0", sz="4")

        c_img = tbl.cell(0, 0)
        c_txt = tbl.cell(0, 1)

        c_img.width = Inches(2.2)
        c_txt.width = Inches(4.3)

        set_cell_background(c_img, "FAFAFA")
        set_cell_margins(c_img, top=100, bottom=100, left=100, right=100)
        set_cell_margins(c_txt, top=100, bottom=100, left=140, right=140)

        # Insertar imagen real
        p_i = c_img.paragraphs[0]
        p_i.alignment = WD_ALIGN_PARAGRAPH.CENTER
        if os.path.exists(img_path):
            run_i = p_i.add_run()
            run_i.add_picture(img_path, width=Inches(2.05))
            p_cap = c_img.add_paragraph()
            p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_cap.paragraph_format.space_before = Pt(4)
            r_cap = p_cap.add_run(f"Figura {sc['num']}. Captura real en dispositivo Android.")
            r_cap.font.size = Pt(8)
            r_cap.italic = True
            r_cap.font.color.rgb = COLOR_MUTED
        else:
            p_i.add_run(f"[Imagen {sc['img']} no encontrada]")

        # Insertar metadatos descriptivos en columna derecha
        p_meta = c_txt.paragraphs[0]
        p_meta.paragraph_format.space_after = Pt(4)
        
        r_rf_l = p_meta.add_run("Requisitos Asociados: ")
        r_rf_l.bold = True
        r_rf_l.font.size = Pt(9.5)
        r_rf_v = p_meta.add_run(f"{sc['rf']}\n")
        r_rf_v.font.size = Pt(9.5)

        r_act_l = p_meta.add_run("Actores / Perfiles: ")
        r_act_l.bold = True
        r_act_l.font.size = Pt(9.5)
        r_act_v = p_meta.add_run(f"{sc['actor']}\n")
        r_act_v.font.size = Pt(9.5)

        # Función que cumple
        p_func = c_txt.add_paragraph()
        p_func.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p_func.paragraph_format.space_after = Pt(4)
        r_fl = p_func.add_run("Función que cumple:\n")
        r_fl.bold = True
        r_fl.font.size = Pt(9.5)
        r_fv = p_func.add_run(sc['func'])
        r_fv.font.size = Pt(9)

        # Componentes UI
        p_comp = c_txt.add_paragraph()
        p_comp.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p_comp.paragraph_format.space_after = Pt(4)
        r_cl = p_comp.add_run("Componentes de la Interfaz:\n")
        r_cl.bold = True
        r_cl.font.size = Pt(9.5)
        r_cv = p_comp.add_run(sc['components'])
        r_cv.font.size = Pt(8.5)

        # Criterios de usabilidad
        p_us = c_txt.add_paragraph()
        p_us.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        r_ul = p_us.add_run("Usabilidad y Adaptación a Campo:\n")
        r_ul.bold = True
        r_ul.font.size = Pt(9.5)
        r_uv = p_us.add_run(sc['usability'])
        r_uv.font.size = Pt(8.5)

        doc.add_paragraph()

    # Guardar archivo
    doc.save(OUT_PATH)
    print(f"DOCUMENTO 02 CON 10 CAPTURAS REALES GUARDADO CON ÉXITO EN: {OUT_PATH}")

if __name__ == "__main__":
    generate_doc_02()
