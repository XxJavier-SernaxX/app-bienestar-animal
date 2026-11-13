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

run_t = p_title.add_run('MODELADO DEL PROCESO, MODELO DE DATOS Y EXPERIMENTACIÓN\nPROYECTO INTEGRADOR II (SEGUNDO PARCIAL)')
run_t.bold = True
run_t.font.size = Pt(12)
run_t.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

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

# -------------------------------------------------------------
# 1. MODELADO DEL PROCESO (BPMN)
# -------------------------------------------------------------
p_s1 = doc.add_paragraph()
r_s1 = p_s1.add_run('1. MODELADO DEL PROCESO DE AUDITORÍA Y EVALUACIÓN (BPMN)')
r_s1.bold = True
r_s1.font.size = Pt(11)
r_s1.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

p_bpmn_intro = doc.add_paragraph()
p_bpmn_intro.add_run('El proceso de auditoría y evaluación técnica del bienestar animal en la Granja Experimental de la UFPSO sigue un flujo secuencial estructurado entre tres actores principales: el Evaluador/Operario de Campo, la Aplicación Móvil SIBA (Capa Local SQLite) y los Servicios en la Nube (Google Firebase). A continuación se describe el ciclo completo mediante estándar de notación BPMN:')

bpmn_steps = [
    ('Inicio del Proceso', 'Evaluador / Operario', 'El evaluador ingresa a los módulos pecuarios de la Granja Experimental de la UFPSO y abre la aplicación SIBA en su dispositivo móvil.'),
    ('Autenticación y Sesión', 'SIBA / Firebase Auth', 'El usuario ingresa credenciales institucionales. El sistema valida la sesión con Firebase Auth y genera el token local de seguridad.'),
    ('Selección de la Unidad Productiva', 'Evaluador / SIBA', 'El usuario selecciona la especie a inspeccionar: Módulo Porcino o Módulo Avícola de Postura.'),
    ('Navegación por Categorías', 'SIBA (UI)', 'La aplicación despliega las 3 categorías normativas oficiales: 1. Recursos de Alojamiento, 2. Evaluación del Animal, y 3. Gestión y Manejo Sanitario.'),
    ('Auditoría de Indicador Específico', 'Evaluador / Granja', 'El evaluador inspecciona in situ el indicador (ej. "Acceso al Agua", "Condición Corporal" o "Deformidad de Quilla").'),
    ('Calificación con Escala Ordinal', 'Evaluador / SIBA', 'Selecciona la opción correspondiente en pantalla (100, 80, 55, 20 o 0 puntos) según la situación observable del lote bajo la Resolución 136 de 2020.'),
    ('Captura de Evidencia Fotográfica', 'Evaluador / Cámara', 'Activa la cámara del dispositivo móvil mediante ImagePicker y captura una fotografía testimonial del corral, nidal, ave o comedero evaluado.'),
    ('Registro de Observaciones', 'Evaluador / SIBA', 'Ingresa notas técnicas adicionales en el campo de texto libre para enriquecer el dictamen.'),
    ('Persistencia Atómica Local (Offline)', 'SIBA / SQLite', 'La aplicación almacena el registro en la base de datos relacional SQLite (tabla "responses") y actualiza el estado en SharedPreferences sin requerir Internet.'),
    ('Comprobación de Ciclo de Categoría', 'SIBA (Decisión)', '¿Se han completado todos los indicadores de la categoría? Si NO, retorna a la lista; si SÍ, avanza a la siguiente categoría.'),
    ('Cálculo Automatizado de Índices', 'SIBA (Motor de Cálculo)', 'Al finalizar la auditoría, el sistema calcula automáticamente los Índices de Categoría (IBC) y el Índice Global de Bienestar Animal (IGBA) con su semáforo visual.'),
    ('Generación de Entregables de Salida', 'SIBA / Export Services', 'El evaluador genera inmediatamente el Informe Ejecutivo en PDF para archivo oficial y la sábana de datos en Microsoft Excel para bioestadística.'),
    ('Sincronización Perimetral en la Nube', 'SIBA / Firebase Sync', 'Al detectar reconexión a Internet en el campus, el servicio de sincronización envía las evaluaciones a Cloud Firestore y sube las fotos a Firebase Storage.'),
    ('Fin del Proceso', 'Sistema / ICA / UFPSO', 'El informe y los datos quedan disponibles para auditorías del ICA, la Dirección de Granja y proyectos de investigación formativa.')
]

t_bpmn = doc.add_table(rows=1, cols=3)
t_bpmn.alignment = WD_TABLE_ALIGNMENT.CENTER
hdr_b = t_bpmn.rows[0].cells
hdr_b[0].text = 'Paso / Fase'
hdr_b[1].text = 'Carril / Responsable'
hdr_b[2].text = 'Descripción de la Actividad en el Proceso'
for c in hdr_b:
    set_cell_background(c, '004D40')
    set_cell_margins(c)
    p = c.paragraphs[0]
    p.runs[0].font.bold = True
    p.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

for pso, car, desc in bpmn_steps:
    row = t_bpmn.add_row().cells
    row[0].text = pso
    row[1].text = car
    row[2].text = desc
    row[0].paragraphs[0].runs[0].font.bold = True
    for c in row:
        set_cell_margins(c, top=80, bottom=80, left=100, right=100)

doc.add_paragraph().paragraph_format.space_after = Pt(12)

# -------------------------------------------------------------
# 2. MODELO DE DATOS (RELACIONAL SQLITE Y NO RELACIONAL FIRESTORE)
# -------------------------------------------------------------
p_s2 = doc.add_paragraph()
r_s2 = p_s2.add_run('2. MODELO DE DATOS: RELACIONAL (SQLITE LOCAL) Y NO RELACIONAL (FIRESTORE CLOUD)')
r_s2.bold = True
r_s2.font.size = Pt(11)
r_s2.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

p_db_intro = doc.add_paragraph()
p_db_intro.add_run('SIBA implementa una arquitectura híbrida de persistencia: un modelo relacional local estructurado en SQLite para asegurar la autonomía offline en los corrales, y un modelo no relacional documental en Google Cloud Firestore para la consolidación institucional.')

# Table SQLite details
p_t_sql = doc.add_paragraph()
p_t_sql.paragraph_format.space_before = Pt(6)
p_t_sql.paragraph_format.space_after = Pt(2)
r_t_sql = p_t_sql.add_run('A. Esquema Relacional Local: Tabla "responses" (SQLite DatabaseHelper.dart)')
r_t_sql.bold = True
r_t_sql.font.size = Pt(10)
r_t_sql.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

sql_fields = [
    ('id', 'INTEGER PRIMARY KEY AUTOINCREMENT', 'Identificador único secuencial de la evaluación en el dispositivo móvil.'),
    ('indicatorId', 'TEXT NOT NULL', 'Clave alfanumérica normalizada del indicador normativo (ej. "acceso_al_agua_flujo").'),
    ('indicatorTitle', 'TEXT NOT NULL', 'Nombre descriptivo formal del indicador según la Resolución 136 de 2020.'),
    ('score', 'INTEGER NOT NULL', 'Calificación ordinal obtenida por el lote (100, 80, 55, 20 o 0 puntos).'),
    ('timestamp', 'TEXT NOT NULL', 'Fecha y hora exacta de captura en formato estándar ISO-8601 (YYYY-MM-DDTHH:MM:SS).'),
    ('evaluador', 'TEXT', 'Nombre o correo del evaluador que ejecutó la auditoría técnica.'),
    ('fecha_evaluacion', 'TEXT', 'Fecha de la visita registrada en formato legible (YYYY-MM-DD).'),
    ('observaciones', 'TEXT', 'Notas técnicas y hallazgos cualitativos registrados por el evaluador.'),
    ('species', 'TEXT NOT NULL', 'Especie animal auditada ("porcinos" o "aves").'),
    ('photo', 'TEXT', 'Ruta absoluta local del archivo de imagen comprimido almacenado en el almacenamiento del celular.'),
    ('synced', 'INTEGER DEFAULT 0', 'Bandera booleana (0: Pendiente, 1: Sincronizado en la nube Firebase).')
]

t_sql = doc.add_table(rows=1, cols=3)
t_sql.alignment = WD_TABLE_ALIGNMENT.CENTER
hdr_s = t_sql.rows[0].cells
hdr_s[0].text = 'Campo (Atributo)'
hdr_s[1].text = 'Tipo de Dato SQL'
hdr_s[2].text = 'Descripción y Restricción'
for c in hdr_s:
    set_cell_background(c, '37474F')
    set_cell_margins(c)
    p = c.paragraphs[0]
    p.runs[0].font.bold = True
    p.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

for fld, tp, desc in sql_fields:
    row = t_sql.add_row().cells
    row[0].text = fld
    row[1].text = tp
    row[2].text = desc
    row[0].paragraphs[0].runs[0].font.bold = True
    for c in row:
        set_cell_margins(c, top=80, bottom=80, left=100, right=100)

doc.add_paragraph().paragraph_format.space_after = Pt(8)

# NoSQL Firestore Structure
p_t_nosql = doc.add_paragraph()
p_t_nosql.paragraph_format.space_before = Pt(6)
p_t_nosql.paragraph_format.space_after = Pt(2)
r_t_nosql = p_t_nosql.add_run('B. Esquema No Relacional Documental: Colecciones Cloud Firestore')
r_t_nosql.bold = True
r_t_nosql.font.size = Pt(10)
r_t_nosql.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

nosql_colls = [
    ('evaluaciones (Colección Raíz)', 'Documento ID: Auto-generado Firestore', 'Almacena la cabecera de la auditoría: { fecha: Timestamp, evaluadorId: String, especie: "porcinos"|"aves", igba_score: Float, dictamen: String, lote: String, estado: "sincronizado" }'),
    ('detalles_indicadores (Subcolección)', 'Subcolección dentro de cada evaluación', 'Almacena cada indicador calificado: { indicatorId: String, score: Number, observaciones: String, photo_url: String (URL en Firebase Storage), categoria: String }'),
    ('usuarios (Colección Raíz)', 'Documento ID: uid de Firebase Auth', 'Almacena el perfil del usuario: { email: String, nombre: String, rol: "admin"|"evaluador"|"operario", institucion: "UFPSO", creado_en: Timestamp }')
]

t_nosql = doc.add_table(rows=1, cols=3)
t_nosql.alignment = WD_TABLE_ALIGNMENT.CENTER
hdr_ns = t_nosql.rows[0].cells
hdr_ns[0].text = 'Colección / Nivel'
hdr_ns[1].text = 'Identificador de Documento'
hdr_ns[2].text = 'Estructura JSON del Documento Documental'
for c in hdr_ns:
    set_cell_background(c, '004D40')
    set_cell_margins(c)
    p = c.paragraphs[0]
    p.runs[0].font.bold = True
    p.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

for col, did, json_str in nosql_colls:
    row = t_nosql.add_row().cells
    row[0].text = col
    row[1].text = did
    row[2].text = json_str
    row[0].paragraphs[0].runs[0].font.bold = True
    for c in row:
        set_cell_margins(c, top=80, bottom=80, left=100, right=100)

doc.add_paragraph().paragraph_format.space_after = Pt(12)

# -------------------------------------------------------------
# 3. EXPERIMENTACIÓN Y PRUEBAS (PLAN DE TESTING)
# -------------------------------------------------------------
p_s3 = doc.add_paragraph()
r_s3 = p_s3.add_run('3. EXPERIMENTACIÓN, PLAN DE PRUEBAS Y VALIDACIÓN EN CAMPO')
r_s3.bold = True
r_s3.font.size = Pt(11)
r_s3.font.color.rgb = RGBColor(0x00, 0x4D, 0x40)

p_test_intro = doc.add_paragraph()
p_test_intro.add_run('La fase de experimentación se diseñó para verificar la robustez funcional del software, la precisión matemática de las fórmulas de la Resolución 136 y la estabilidad de la arquitectura offline-first en condiciones reales de la Granja Experimental de la UFPSO.')

test_cases = [
    ('CP01', 'Autenticación con Credenciales Válidas', 'Ingreso de correo institucional y contraseña correcta con conexión a red.', 'Inicio de sesión exitoso y redirección inmediata a la pantalla de selección de especies.', 'EXITOSA (Aprobada)'),
    ('CP02', 'Navegación e Indicadores por Especie', 'Seleccionar "Porcinos" y luego "Aves de Postura", verificando que carguen las rúbricas correctas.', 'Carga dinámica de los más de 30 indicadores porcinos y más de 24 avícolas sin duplicidad de llaves.', 'EXITOSA (Aprobada)'),
    ('CP03', 'Calificación y Captura de Evidencia Fotográfica', 'Seleccionar calificación (ej. 100 pts), tomar foto con cámara del celular y agregar observaciones.', 'La fotografía se comprime, se almacena localmente y la ruta queda registrada en SQLite.', 'EXITOSA (Aprobada)'),
    ('CP04', 'Resiliencia y Persistencia Offline (Modo Avión)', 'Activar modo avión (sin Wi-Fi ni datos), diligenciar evaluación completa de 10 indicadores y guardar.', 'La app opera al 100%, guarda en SQLite local y marca los indicadores como completados sin errores de red.', 'EXITOSA (Aprobada)'),
    ('CP05', 'Reinicio Inesperado del Dispositivo', 'Reiniciar el celular mientras se encuentra a mitad de una evaluación en campo.', 'Al abrir nuevamente la app, los indicadores previamente calificados se mantienen intactos.', 'EXITOSA (Aprobada)'),
    ('CP06', 'Precisión Matemática del Motor de Cálculo (IGBA)', 'Evaluar indicadores con puntajes conocidos (ej: 100, 55, 0) y verificar el promedio general.', 'El sistema calcula con exactitud matemática el promedio y asigna el semáforo cromático correcto.', 'EXITOSA (Aprobada)'),
    ('CP07', 'Generación de Informe Ejecutivo en PDF', 'Presionar el botón "Exportar PDF" tras completar una auditoría.', 'Se crea el archivo PDF formal tamaño A4 con cabeceras, tablas de indicadores y fotografías adjuntas.', 'EXITOSA (Aprobada)'),
    ('CP08', 'Exportación de Matriz a Microsoft Excel', 'Presionar "Exportar a Excel" en la pantalla de resultados.', 'Se genera el archivo binario XLSX con celdas de tipo TextCellValue compatible con Excel.', 'EXITOSA (Aprobada)'),
    ('CP09', 'Sincronización Perimetral al Detectar Red', 'Desactivar modo avión y conectar a Wi-Fi institucional de la UFPSO.', 'El servicio en segundo plano detecta enlace y envía las evaluaciones pendientes a Cloud Firestore.', 'EXITOSA (Aprobada)'),
    ('CP10', 'Prueba de Usabilidad en Campo con Operarios', 'Prueba con 3 estudiantes de Zootecnia y 1 operario en los galpones de postura de la granja.', 'Tiempo promedio de evaluación por lote: 8.5 minutos (reducción del 65% frente al papel manual).', 'EXITOSA (Aprobada)')
]

t_test = doc.add_table(rows=1, cols=5)
t_test.alignment = WD_TABLE_ALIGNMENT.CENTER
hdr_t = t_test.rows[0].cells
hdr_t[0].text = 'Caso'
hdr_t[1].text = 'Nombre de la Prueba'
hdr_t[2].text = 'Procedimiento / Estímulo'
hdr_t[3].text = 'Resultado Esperado'
hdr_t[4].text = 'Estado de Validación'
for c in hdr_t:
    set_cell_background(c, '004D40')
    set_cell_margins(c)
    p = c.paragraphs[0]
    p.runs[0].font.bold = True
    p.runs[0].font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

for cp, nom, proc, esp, est in test_cases:
    row = t_test.add_row().cells
    row[0].text = cp
    row[1].text = nom
    row[2].text = proc
    row[3].text = esp
    row[4].text = est
    row[0].paragraphs[0].runs[0].font.bold = True
    row[4].paragraphs[0].runs[0].font.bold = True
    for c in row:
        set_cell_margins(c, top=80, bottom=80, left=90, right=90)

doc.add_paragraph().paragraph_format.space_after = Pt(12)

# Save document
out_path = r'C:\Users\User\Desktop\ENTREGABLES_SEGUNDO_PARCIAL_SIBA\03_MODELADO_PROCESO_DATOS_Y_PRUEBAS_SIBA.docx'
doc.save(out_path)
print('SUCCESS_SAVED:', out_path)
