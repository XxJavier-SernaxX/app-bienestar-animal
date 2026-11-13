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

# Title
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

run_t = p_title.add_run('FORMATO DISEÑO DE INTERFACES DE USUARIO (UI/UX)\nPROYECTO INTEGRADOR II (SEGUNDO PARCIAL)')
run_t.bold = True
run_t.font.size = Pt(12)
run_t.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

# Goal box from original template
p_goal = doc.add_paragraph()
p_goal.paragraph_format.space_before = Pt(8)
p_goal.paragraph_format.space_after = Pt(8)
r_obj = p_goal.add_run('Objetivo: ')
r_obj.bold = True
p_goal.add_run('Definir y desarrollar una interfaz de usuario intuitiva, funcional y atractiva, que facilite la interacción del usuario con el sistema, garantizando una experiencia de uso eficiente, accesible y centrada en las necesidades del usuario final en condiciones reales de la Granja Experimental de la UFPSO.\n')
r_ten = p_goal.add_run('Tener en cuenta: ')
r_ten.bold = True
p_goal.add_run('El formato contiene el desglose estructurado de las 8 pantallas principales de la aplicación móvil nativa SIBA (desarrollada en Flutter), describiendo su objetivo, componentes visuales interactivos, paleta de colores accesible, flujo de eventos y función que cumple dentro de la evaluación conforme a la Resolución 136 de 2020.')

# Metadata
p_meta = doc.add_paragraph()
p_meta.paragraph_format.space_after = Pt(12)
p_meta.add_run('Proyecto: ').bold = True
p_meta.add_run('SIBA: Sistema de Bienestar Animal — Granja Experimental UFPSO\n')
p_meta.add_run('Integrantes: ').bold = True
p_meta.add_run('Javier Mauricio Serna Osorio (0192546) — Juan Manuel Garrido Amaya (0192544)\n')
p_meta.add_run('Grupo de Investigación: ').bold = True
p_meta.add_run('GRIITEM  |  ')
p_meta.add_run('Modalidad: ').bold = True
p_meta.add_run('SE APRENDE\n')

# Screens detail
screens = [
    {
        'num': '01',
        'name': 'Pantalla de Autenticación / Inicio de Sesión (login_page.dart)',
        'type': 'Móvil Android / iOS (Flutter)',
        'objective': 'Garantizar el acceso seguro e individualizado de los evaluadores, administradores y operarios mediante Firebase Authentication.',
        'elements': [
            'Logotipo institucional SIBA y cabecera de la UFPSO.',
            'Campo de texto para correo electrónico institucional (@ufpso.edu.co) con validación de sintaxis.',
            'Campo de texto para contraseña con botón para alternar visibilidad (icono de ojo).',
            'Botón de acción principal "Iniciar Sesión" con animación de carga circular (CircularProgressIndicator).',
            'Enlace para recuperación de contraseña y cambio de credenciales vía correo.',
            'Manejo de errores amigable mediante SnackBar (credenciales incorrectas o sin conexión).'
        ],
        'ux_decision': 'Diseño minimalista con alto contraste para facilitar el ingreso de credenciales en exteriores con luz solar.',
        'color_palette': 'Verde institucional Teal (#004D40), Blanco puro (#FFFFFF), Gris claro de fondo (#F5F5F5).'
    },
    {
        'num': '02',
        'name': 'Pantalla de Selección de Especie (species_selection.dart)',
        'type': 'Móvil Android / iOS (Flutter)',
        'objective': 'Permitir al evaluador elegir qué unidad productiva de la Granja Experimental se va a auditar.',
        'elements': [
            'Barra superior (AppBar) con título "SIBA - Selección de Especie" y botón de menú lateral.',
            'Tarjeta interactiva 1: "Porcinos (Sus scrofa domesticus)", con ilustración gráfica, resumen de categorías y botón de acceso.',
            'Tarjeta interactiva 2: "Aves de Postura (Gallus gallus domesticus)", con ilustración representativa y acceso a sus formularios.',
            'Indicador de estado que muestra si existen evaluaciones guardadas pendientes por sincronizar.',
            'Bordes redondeados con elevación de sombra para denotar interactividad táctil.'
        ],
        'ux_decision': 'Tarjetas de gran tamaño (Cards) con feedback táctil (InkWell) que previenen toques involuntarios.',
        'color_palette': 'Verde Teal (#004D40), Acentos Naranja cálido (#FF6F00), Fondo (#FAFAFA).'
    },
    {
        'num': '03',
        'name': 'Menú Lateral de Navegación (menu_drawer.dart)',
        'type': 'Componente Global Desplegable (Drawer)',
        'objective': 'Proporcionar acceso inmediato a todas las funciones del sistema desde cualquier punto de la aplicación.',
        'elements': [
            'Cabecera de usuario con avatar, nombre del evaluador y rol activo (Administrador, Evaluador o Estudiante).',
            'Opción "Inicio": Retorna a la selección de especies.',
            'Opción "Porcinos": Acceso directo a las 3 categorías porcinas.',
            'Opción "Aves de Postura": Acceso directo a las 3 categorías avícolas.',
            'Opción "Resultados Guardados": Visualización del historial de auditorías y promedios en SQLite.',
            'Opción "Exportar Reportes": Generación de PDF y Excel.',
            'Opción "Sincronizar": Disparador manual para enviar datos a Firebase.',
            'Opción "Cerrar Sesión": Salida segura de la aplicación.'
        ],
        'ux_decision': 'Estructura estándar de Material Design que garantiza familiaridad y aprendizaje inmediato.',
        'color_palette': 'Header Teal oscuro (#004D40), Iconos gris pizarra (#455A64), Texto (#212121).'
    },
    {
        'num': '04',
        'name': 'Listado de Indicadores por Categoría (indicator_list.dart)',
        'type': 'Móvil Android / iOS (Flutter)',
        'objective': 'Listar de forma jerárquica y secuencial los indicadores oficiales de la Resolución 136 para la categoría seleccionada.',
        'elements': [
            'Barra de navegación con el nombre de la categoría (Recursos, Animal o Gestión) y la especie activa.',
            'Indicador de progreso superior (Barra lineal) con el porcentaje completado (ej. "7 de 18 indicadores evaluados").',
            'Lista scrolleable de tarjetas por indicador con título claro (ej. "Acceso al Agua", "Condición Corporal").',
            'Icono de estado visual en cada tarjeta: Checkmark verde si ya fue evaluado, o círculo gris si está pendiente.',
            'Lectura asíncrona de persistencia local: Al entrar, la pantalla lee de SharedPreferences y SQLite para marcar los ítems completados.',
            'Transición fluida a la pantalla de detalle del indicador al presionar cualquier tarjeta.'
        ],
        'ux_decision': 'La retroalimentación visual inmediata evita que el evaluador salte indicadores obligatorios de la norma.',
        'color_palette': 'Verde éxito (#2E7D32), Fondo Teal muy suave (#E0F2F1), Blanco (#FFFFFF).'
    },
    {
        'num': '05',
        'name': 'Pantalla de Evaluación de Indicador en Detalle (indicator_detail.dart)',
        'type': 'Móvil Android / iOS (Flutter)',
        'objective': 'Formulario núcleo donde se asigna la calificación ordinal bajo la Resolución 136, se toma la fotografía y se registran observaciones.',
        'elements': [
            'Título superior con el nombre del indicador normativo.',
            'Selector de calificación con 4 o 5 botones radiales estilizados que muestran la puntuación (100, 80, 55, 20 o 0) y el descriptor técnico oficial exacto de la Resolución 136.',
            'Sección multimedia de evidencia con botón "Tomar Fotografía" (ImagePicker) que activa la cámara del celular.',
            'Visor de previsualización de la foto capturada en miniatura con opción de retoma.',
            'Campo de texto multilinea para "Observaciones Técnicas de Campo".',
            'Botón destacado "Guardar Resultado": Guarda atómicamente en SQLite local y SharedPreferences, confirmando con SnackBar verde.'
        ],
        'ux_decision': 'Textos de calificación autoexplicativos que eliminan la necesidad de cargar con manuales impresos en los corrales.',
        'color_palette': 'Botones de opción Teal (#00796B), Fondo (#F5F5F5), Alerta roja si falta calificación (#D32F2F).'
    },
    {
        'num': '06',
        'name': 'Pantalla de Resultados y Cálculo del Índice (result_page.dart)',
        'type': 'Móvil Android / iOS (Flutter)',
        'objective': 'Consolidar las evaluaciones del lote, ejecutar el motor de cálculo y presentar el dictamen zootécnico semaforizado.',
        'elements': [
            'Tarjeta de resumen principal superior con el Índice Global de Bienestar Animal (IGBA) en números grandes (ej. "88.5 / 100").',
            'Semáforo visual dinámico con color y mensaje de dictamen: Verde ("Excelente"), Amarillo ("Bueno"), Naranja ("Regular") o Rojo ("Deficiente").',
            'Desglose analítico de puntuaciones obtenidas por categoría (Recursos, Animal y Gestión).',
            'Lista de todas las respuestas registradas en SQLite con el puntaje, miniatura de foto y botón para ver detalles.',
            'Barra de acciones inferiores para generar informe PDF o exportar Excel.'
        ],
        'ux_decision': 'Uso de código semafórico intuitivo para que el personal de granja entienda el estado general del lote en 3 segundos.',
        'color_palette': 'Verde (#2E7D32), Amarillo (#F9A825), Naranja (#D84315), Rojo (#C62828).'
    },
    {
        'num': '07',
        'name': 'Módulo de Exportación y Generación de Informe PDF (export_pdf_service.dart)',
        'type': 'Servicio Móvil / Generador de Documentos',
        'objective': 'Producir un documento PDF formal, estructurado e imprimible para auditorías del ICA y archivo institucional de la UFPSO.',
        'elements': [
            'Encabezado institucional: "Universidad Francisco de Paula Santander Ocaña - Granja Experimental".',
            'Metadatos de auditoría: Fecha, hora, evaluador responsable, lote y especie auditada.',
            'Cuadro de dictamen técnico con el puntaje global IGBA y nivel de bienestar alcanzado.',
            'Tabla detallada de indicadores con código, criterio, puntuación obtenida y observaciones técnicas.',
            'Sección de anexos fotográficos integrados con pie de foto explicativo.',
            'Espacios para firma del Evaluador Técnico y del Administrador de la Granja.',
            'Diálogo de previsualización e integración con el visor PDF nativo del dispositivo y opción de compartir vía WhatsApp/Correo.'
        ],
        'ux_decision': 'Diseño ejecutivo tamaño A4 que cumple formalmente con el estándar documental exigido por inspectores sanitarios.',
        'color_palette': 'Formato monocromático profesional con acentos Teal oscuro (#004D40).'
    },
    {
        'num': '08',
        'name': 'Módulo de Exportación a Hoja de Cálculo Excel (export_service.dart)',
        'type': 'Servicio Móvil / Generador de Datos',
        'objective': 'Generar una matriz estructurada (.xlsx) con los datos brutos de las evaluaciones para investigación bioestadística en la UFPSO.',
        'elements': [
            'Generación nativa del archivo binario Excel mediante la librería "excel" de Dart.',
            'Hoja de cálculo nombrada "Resultados" con cabeceras formateadas con TextCellValue.',
            'Columnas generadas: IndicatorId, IndicatorTitle, Score, Timestamp, Evaluador, Fecha_Evaluacion, Observaciones, Species, PhotoPath.',
            'Almacenamiento directo en el directorio de documentos de la aplicación móvil (path_provider).',
            'Diálogo de notificación con la ruta absoluta donde se guardó el archivo y botón para abrirlo inmediatamente en Microsoft Excel o Google Sheets.'
        ],
        'ux_decision': 'Estructura tabular limpia compatible con software estadístico como SPSS, R o Excel para proyectos de grado de la UFPSO.',
        'color_palette': 'Encabezados en verde esmeralda Excel (#107C41) con texto blanco.'
    }
]

for s in screens:
    p_h = doc.add_paragraph()
    p_h.paragraph_format.space_before = Pt(10)
    p_h.paragraph_format.space_after = Pt(4)
    r_h = p_h.add_run(f"PANTALLA {s['num']}: {s['name']}")
    r_h.bold = True
    r_h.font.size = Pt(11)
    r_h.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

    t = doc.add_table(rows=5, cols=2)
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    
    rows_def = [
        ('Tipo de Pantalla / Componente', s['type']),
        ('Objetivo Funcional', s['objective']),
        ('Componentes y Elementos Visuales', '\n'.join(['• ' + el for el in s['elements']])),
        ('Decisión de Diseño y Usabilidad (UX)', s['ux_decision']),
        ('Paleta Cromática y Accesibilidad', s['color_palette'])
    ]

    for idx, (lbl, val) in enumerate(rows_def):
        row_cells = t.rows[idx].cells
        row_cells[0].text = lbl
        row_cells[0].paragraphs[0].runs[0].font.bold = True
        row_cells[0].paragraphs[0].runs[0].font.size = Pt(9)
        set_cell_background(row_cells[0], 'E0F2F1')
        
        row_cells[1].text = val
        row_cells[1].paragraphs[0].runs[0].font.size = Pt(9)
        set_cell_background(row_cells[1], 'FFFFFF')

    for r in t.rows:
        for c in r.cells:
            set_cell_margins(c, top=80, bottom=80, left=120, right=120)

    doc.add_paragraph().paragraph_format.space_after = Pt(8)

# Save document
out_path = r'C:\Users\User\Desktop\ENTREGABLES_SEGUNDO_PARCIAL_SIBA\02_FORMATO_DISENO_DE_INTERFACES_UI_UX_SIBA.docx'
doc.save(out_path)
print('SUCCESS_SAVED:', out_path)
