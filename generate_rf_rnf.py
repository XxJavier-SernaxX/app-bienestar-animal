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

run_t = p_title.add_run('ESPECIFICACIÓN DE REQUISITOS FUNCIONALES Y NO FUNCIONALES\nPROYECTO INTEGRADOR II (SEGUNDO PARCIAL)')
run_t.bold = True
run_t.font.size = Pt(12)
run_t.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

# Project metadata block
p_meta = doc.add_paragraph()
p_meta.paragraph_format.space_after = Pt(12)
p_meta.add_run('Proyecto: ').bold = True
p_meta.add_run('SIBA: Sistema de Bienestar Animal — Digitalización y estandarización de la evaluación en cerdos y aves de postura (Resolución 136 de 2020)\n')
p_meta.add_run('Integrantes: ').bold = True
p_meta.add_run('Javier Mauricio Serna Osorio (0192546) — Juan Manuel Garrido Amaya (0192544)\n')
p_meta.add_run('Grupo de Investigación: ').bold = True
p_meta.add_run('GRIITEM  |  ')
p_meta.add_run('Modalidad: ').bold = True
p_meta.add_run('SE APRENDE  |  ')
p_meta.add_run('Entorno: ').bold = True
p_meta.add_run('Granja Experimental UFPSO\n')

# Section 1: Actores / Usuarios del Sistema
p_s1 = doc.add_paragraph()
r_s1 = p_s1.add_run('1. ACTORES Y PERFILES DEL SISTEMA')
r_s1.bold = True
r_s1.font.size = Pt(11)
r_s1.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

actors = [
    ('U001', 'Administrador del Sistema', 'Personal responsable de la gestión de usuarios, roles institucionales, parametrización de catálogos y monitoreo del flujo de sincronización cloud.'),
    ('U002', 'Evaluador / Médico Veterinario / Zootecnista', 'Docente, investigador o profesional zootecnista encargado de realizar la auditoría técnica de bienestar animal en la granja, calificar indicadores bajo la Resolución 136, registrar observaciones y emitir dictámenes.'),
    ('U003', 'Operario de Granja / Estudiante en Práctica', 'Trabajador de campo o estudiante que registra variables cotidianas de recursos, alimentación y salud, capturando evidencias fotográficas y operando la app sin conexión a Internet.'),
    ('U004', 'Directivo / Inspector ICA (Consulta)', 'Rol auditor que consulta los informes ejecutivos consolidados, el historial de índices globales (IGBA) y las matrices exportadas en PDF y Excel.')
]

t_act = doc.add_table(rows=1, cols=3)
t_act.alignment = WD_TABLE_ALIGNMENT.CENTER
hdr_act = t_act.rows[0].cells
hdr_act[0].text = 'Código'
hdr_act[1].text = 'Nombre del Usuario'
hdr_act[2].text = 'Descripción del Rol en SIBA'
for c in hdr_act:
    set_cell_background(c, '004D40')
    set_cell_margins(c)
    p = c.paragraphs[0]
    p.runs[0].font.bold = True
    p.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

for cod, nom, desc in actors:
    row = t_act.add_row().cells
    row[0].text = cod
    row[1].text = nom
    row[2].text = desc
    row[0].paragraphs[0].runs[0].font.bold = True
    row[1].paragraphs[0].runs[0].font.bold = True
    for c in row:
        set_cell_margins(c)

doc.add_paragraph().paragraph_format.space_after = Pt(12)

# Section 2: Requisitos Funcionales por Usuario (Formato Oficial)
p_s2 = doc.add_paragraph()
r_s2 = p_s2.add_run('2. FORMATOS OFICIALES DE REQUISITOS FUNCIONALES')
r_s2.bold = True
r_s2.font.size = Pt(11)
r_s2.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

user_rf_data = [
    {
        'code': 'U001',
        'name': 'Administrador',
        'desc': 'Administrador del sistema y gestión de plataforma',
        'rfs': [
            ('RF01', 'Gestionar Usuarios y Roles', 'Permite registrar, actualizar, suspender y asignar roles (Administrador, Evaluador, Operario, Auditor) con credenciales de Firebase Authentication.'),
            ('RF02', 'Parametrizar Catálogo de Indicadores', 'Permite consultar y verificar los indicadores zootécnicos oficiales cargados para Porcinos y Aves de postura según la Resolución 136 de 2020.'),
            ('RF03', 'Monitorear Estado de Sincronización', 'Visualizar el estado de sincronización entre las bases de datos locales SQLite de los dispositivos y Firestore en la nube.'),
            ('RF04', 'Gestionar Respaldos y Purga de Evidencias', 'Permitir la descarga consolidada de registros de auditoría y la gestión de evidencias fotográficas en Firebase Storage.')
        ]
    },
    {
        'code': 'U002',
        'name': 'Evaluador Técnico (MVZ / Zootecnista / Docente)',
        'desc': 'Profesional responsable de la evaluación técnica y dictamen del bienestar animal',
        'rfs': [
            ('RF05', 'Iniciar Sesión e Identificar Predio', 'Autenticación con usuario y contraseña; selección de la Granja Experimental UFPSO y módulo específico de evaluación.'),
            ('RF06', 'Seleccionar Especie de Evaluación', 'Elegir entre Porcinos (Sus scrofa domesticus) y Aves de postura (Gallus gallus domesticus) para cargar la lista correspondiente.'),
            ('RF07', 'Navegar por Categorías Normativas', 'Visualizar los indicadores organizados en Recursos de Alojamiento, Evaluación del Animal y Gestión Sanitaria.'),
            ('RF08', 'Evaluar Indicador con Escala Ordinal', 'Seleccionar la calificación del indicador conforme a la Resolución 136 (100: Excelente, 80: Bueno, 55: Aceptable, 20: Crítico, 0: Deficiente) con descripción técnica visible.'),
            ('RF09', 'Capturar Evidencia Fotográfica en Vivo', 'Acceder a la cámara del dispositivo móvil para tomar una fotografía in situ del corral, nidal, plumaje o comedero auditado.'),
            ('RF10', 'Registrar Observaciones Cualitativas', 'Ingresar notas técnicas detalladas sobre hallazgos específicos observados en el lote de animales.'),
            ('RF11', 'Calcular Automáticamente Índices (IBC e IGBA)', 'Procesar instantáneamente el promedio por categoría y el Índice Global de Bienestar Animal con semáforo cromático (verde, amarillo, naranja, rojo).'),
            ('RF12', 'Generar y Exportar Informe Ejecutivo PDF', 'Producir un informe formal con fecha, lote, evaluador, calificaciones detalladas, observaciones y fotografías adjuntas.'),
            ('RF13', 'Exportar Sábana de Datos a Excel', 'Generar archivo XLSX estructurado con las variables auditadas para análisis bioestadístico e investigación en la UFPSO.')
        ]
    },
    {
        'code': 'U003',
        'name': 'Operario de Granja / Estudiante en Práctica',
        'desc': 'Personal operativo de campo encargado de recolección en galpones y corrales',
        'rfs': [
            ('RF14', 'Operación Autónoma Sin Conexión (Offline-First)', 'Permitir el diligenciamiento completo de evaluaciones y toma de fotos en galpones y corrales sin acceso a Wi-Fi o datos celulares.'),
            ('RF15', 'Persistencia Local en Dispositivo', 'Guardar todas las calificaciones y rutas de fotografías en la base de datos relacional local SQLite y SharedPreferences.'),
            ('RF16', 'Sincronización Automática Perimetral', 'Detectar automáticamente la reconexión a Internet y sincronizar las evaluaciones pendientes hacia Firebase Firestore y Storage.'),
            ('RF17', 'Consultar Historial Local de Evaluaciones', 'Revisar en el dispositivo móvil las auditorías realizadas en el día y el avance porcentual de indicadores completados.')
        ]
    }
]

for u in user_rf_data:
    t = doc.add_table(rows=4 + len(u['rfs']), cols=3)
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    
    # Row 0: Codigo
    t.rows[0].cells[0].merge(t.rows[0].cells[1])
    t.rows[0].cells[0].text = 'Código:'
    t.rows[0].cells[2].text = u['code']
    set_cell_background(t.rows[0].cells[0], 'E0F2F1')
    set_cell_background(t.rows[0].cells[2], 'FFFFFF')
    
    # Row 1: Nombre
    t.rows[1].cells[0].merge(t.rows[1].cells[1])
    t.rows[1].cells[0].text = 'Nombre del Usuario:'
    t.rows[1].cells[2].text = u['name']
    set_cell_background(t.rows[1].cells[0], 'E0F2F1')
    set_cell_background(t.rows[1].cells[2], 'FFFFFF')

    # Row 2: Descripcion
    t.rows[2].cells[0].merge(t.rows[2].cells[1])
    t.rows[2].cells[0].text = 'Descripción:'
    t.rows[2].cells[2].text = u['desc']
    set_cell_background(t.rows[2].cells[0], 'E0F2F1')
    set_cell_background(t.rows[2].cells[2], 'FFFFFF')

    # Row 3: Header RFs
    t.rows[3].cells[1].merge(t.rows[3].cells[2])
    t.rows[3].cells[0].text = 'Código'
    t.rows[3].cells[1].text = 'Requisito Funcional y Descripción'
    set_cell_background(t.rows[3].cells[0], '004D40')
    set_cell_background(t.rows[3].cells[1], '004D40')
    for cell in [t.rows[3].cells[0], t.rows[3].cells[1]]:
        p = cell.paragraphs[0]
        p.runs[0].font.bold = True
        p.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    # Fill RFs
    for idx, (rf_cod, rf_nom, rf_det) in enumerate(u['rfs']):
        row_cells = t.rows[4 + idx].cells
        row_cells[1].merge(row_cells[2])
        row_cells[0].text = rf_cod
        row_cells[0].paragraphs[0].runs[0].font.bold = True
        
        p_desc = row_cells[1].paragraphs[0]
        r_bold = p_desc.add_run(rf_nom + ': ')
        r_bold.bold = True
        p_desc.add_run(rf_det)
        
        bg = 'F9FBE7' if idx % 2 == 0 else 'FFFFFF'
        set_cell_background(row_cells[0], bg)
        set_cell_background(row_cells[1], bg)

    for row in t.rows:
        for c in row.cells:
            set_cell_margins(c, top=80, bottom=80, left=120, right=120)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

# Section 3: Requisitos No Funcionales (RNF)
p_s3 = doc.add_paragraph()
r_s3 = p_s3.add_run('3. ESPECIFICACIÓN DE REQUISITOS NO FUNCIONALES (RNF)')
r_s3.bold = True
r_s3.font.size = Pt(11)
r_s3.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

rnfs = [
    ('RNF01', 'Disponibilidad / Autonomía Offline', 'Usabilidad / Arquitectura', 'El sistema debe permitir el 100% de las funciones de captura, calificación y almacenamiento local sin requerir conexión a Internet en los galpones y corrales de la Granja UFPSO.'),
    ('RNF02', 'Rendimiento y Tiempo de Respuesta', 'Rendimiento', 'El guardado de evaluaciones en SQLite y la apertura de formularios de indicadores debe realizarse en un tiempo inferior a 1 segundo.'),
    ('RNF03', 'Compatibilidad Multiplataforma', 'Portabilidad', 'La aplicación debe compilarse y ejecutarse de forma nativa en sistemas operativos Android (versión 8.0 en adelante) e iOS bajo framework Flutter.'),
    ('RNF04', 'Seguridad y Privacidad', 'Seguridad', 'Las credenciales de acceso deben autenticarse mediante Firebase Auth con cifrado SSL/TLS. La base de datos SQLite no debe exponer contraseñas en texto plano.'),
    ('RNF05', 'Integridad y Persistencia de Datos', 'Confiabilidad', 'Si el dispositivo se reinicia o apaga inesperadamente en campo, los datos previamente guardados en SQLite y SharedPreferences no deben sufrir corrupción ni pérdida.'),
    ('RNF06', 'Optimización de Multimedia', 'Almacenamiento', 'Las fotografías capturadas como evidencia deben ser comprimidas localmente para evitar saturar el almacenamiento del dispositivo y optimizar el consumo de ancho de banda al sincronizar.'),
    ('RNF07', 'Usabilidad y Experiencia de Usuario', 'Usabilidad (UI/UX)', 'Las interfaces deben emplear fuentes legibles (mínimo 14pt), botones con área táctil amplia y esquemas de color semaforizados aptos para visualización bajo luz solar directa en campo.'),
    ('RNF08', 'Cumplimiento Normativo Estricto', 'Legal / Calidad', 'Los descriptores y fórmulas deben apegarse fielmente a las directrices de bienestar animal estipuladas en la Resolución 136 de 2020 del MADR e ICA.')
]

t_rnf = doc.add_table(rows=1, cols=4)
t_rnf.alignment = WD_TABLE_ALIGNMENT.CENTER
hdr_rnf = t_rnf.rows[0].cells
hdr_rnf[0].text = 'Código'
hdr_rnf[1].text = 'Nombre del Requisito'
hdr_rnf[2].text = 'Categoría ISO 25010'
hdr_rnf[3].text = 'Descripción y Criterio de Aceptación'

for c in hdr_rnf:
    set_cell_background(c, '37474F')
    set_cell_margins(c)
    p = c.paragraphs[0]
    p.runs[0].font.bold = True
    p.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

for cod, nom, cat, desc in rnfs:
    row = t_rnf.add_row().cells
    row[0].text = cod
    row[1].text = nom
    row[2].text = cat
    row[3].text = desc
    row[0].paragraphs[0].runs[0].font.bold = True
    row[1].paragraphs[0].runs[0].font.bold = True
    for c in row:
        set_cell_margins(c, top=80, bottom=80, left=100, right=100)

doc.add_paragraph().paragraph_format.space_after = Pt(12)

# Save document
out_path = r'C:\Users\User\Desktop\ENTREGABLES_SEGUNDO_PARCIAL_SIBA\01_FORMATO_REQUISITOS_FUNCIONALES_Y_NO_FUNCIONALES_SIBA.docx'
doc.save(out_path)
print('SUCCESS_SAVED:', out_path)
