// api/evaluaciones.js
// -----------------------------------------------------------------------------
// Vercel Serverless Function: Recibe evaluaciones desde la APK Android de SIBA
// y las almacena / consulta en tiempo real para el Panel Web de Administración.
// -----------------------------------------------------------------------------

export default async function handler(req, res) {
  // Configurar CORS para permitir peticiones desde la APK y desde el navegador
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, apikey');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // OBTENER EVALUACIONES (GET)
  if (req.method === 'GET') {
    // Si hay variables de entorno de Supabase configuradas en Vercel, consultar Supabase
    const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

    if (supabaseUrl && supabaseKey) {
      try {
        const response = await fetch(`${supabaseUrl}/rest/v1/evaluaciones?order=created_at.desc`, {
          headers: {
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`
          }
        });
        const data = await response.json();
        return res.status(200).json({ source: 'supabase', count: data.length, data });
      } catch (err) {
        return res.status(500).json({ error: 'Error al consultar Supabase', details: err.message });
      }
    }

    return res.status(200).json({
      source: 'memory_default',
      message: 'Panel SIBA listo. Configura SUPABASE_URL para persistencia permanente en la nube.'
    });
  }

  // GUARDAR EVALUACIÓN DESDE APK ANDROID (POST)
  if (req.method === 'POST') {
    const body = req.body;

    if (!body || !body.especie || !body.lote_codigo) {
      return res.status(400).json({ error: 'Datos incompletos. Se requiere especie y lote_codigo.' });
    }

    // Registrar en Supabase si está configurado
    const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

    if (supabaseUrl && supabaseKey) {
      try {
        const insertRes = await fetch(`${supabaseUrl}/rest/v1/evaluaciones`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`,
            'Prefer': 'return=representation'
          },
          body: JSON.stringify(body)
        });
        const saved = await insertRes.json();
        return res.status(201).json({
          status: 'success',
          message: 'Evaluación recibida desde APK y guardada en Supabase PostgreSQL.',
          record: saved
        });
      } catch (e) {
        return res.status(500).json({ error: 'Fallo al insertar en Supabase', details: e.message });
      }
    }

    // Respuesta exitosa de recepción
    return res.status(201).json({
      status: 'received',
      message: 'Evaluación recibida exitosamente en el backend de Vercel.',
      received_at: new Date().toISOString(),
      record: body
    });
  }

  return res.status(405).json({ error: 'Método no permitido' });
}
