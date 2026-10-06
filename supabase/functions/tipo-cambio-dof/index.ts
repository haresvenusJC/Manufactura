// Lee el tipo de cambio (dólar) de la caja "Indicadores" de la página principal del DOF.
// Se ejecuta en el servidor de Supabase, así que no tiene problemas de CORS ni necesita token.
// Si el DOF cambia el formato de su página, responde error y la OC pide captura manual.

const CORS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), { status, headers: { ...CORS, 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
    try {
        const res = await fetch('https://www.dof.gob.mx/', { headers: { 'User-Agent': 'Mozilla/5.0' } });
        if (!res.ok) return json({ error: `El DOF respondió ${res.status}` }, 502);
        const html = await res.text();
        const texto = html
            .replace(/<script[\s\S]*?<\/script>/gi, ' ')
            .replace(/<style[\s\S]*?<\/style>/gi, ' ')
            .replace(/<[^>]+>/g, ' ')
            .replace(/&nbsp;/g, ' ')
            .replace(/\s+/g, ' ');
        const m = texto.match(/Tipo de Cambio y Tasas al\s+(\d{2}\/\d{2}\/\d{4})[\s\S]{0,120}?D[OÓ]LAR\s+(\d+(?:\.\d+)?)/i);
        if (!m) return json({ error: 'No se encontró el tipo de cambio en la página del DOF' }, 502);
        const [dd, mm, yyyy] = m[1].split('/');
        return json({
            valor: Number(m[2]),
            fecha: `${yyyy}-${mm}-${dd}`,
            fuente: 'DOF (indicadores)',
            consultado_at: new Date().toISOString(),
        });
    } catch (e) {
        return json({ error: String(e) }, 502);
    }
});
