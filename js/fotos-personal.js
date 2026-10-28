import { supabaseClient } from './supabase.js';

// =====================================================================
//  Fotos del personal: bucket PRIVADO 'fotos-personal' (datos personales).
//  Se guarda solo la ruta (empleados.foto_path) y se muestra con URL firmada.
//  Requiere sql/2026-10-28_departamentos_gerente_foto.sql.
// =====================================================================

const BUCKET = 'fotos-personal';
const MAX_LADO = 480;          // px: una foto de ficha no necesita más
const VIGENCIA_URL_SEG = 3600; // las URLs firmadas duran 1 hora

const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// Reduce la foto a JPEG de máximo 480 px por lado (rápida de subir y de mostrar).
export async function comprimirFoto(archivo) {
    const bitmap = await createImageBitmap(archivo);
    const escala = Math.min(1, MAX_LADO / Math.max(bitmap.width, bitmap.height));
    const lienzo = document.createElement('canvas');
    lienzo.width = Math.max(1, Math.round(bitmap.width * escala));
    lienzo.height = Math.max(1, Math.round(bitmap.height * escala));
    lienzo.getContext('2d').drawImage(bitmap, 0, 0, lienzo.width, lienzo.height);
    if (bitmap.close) bitmap.close();
    return new Promise((resolve, reject) => {
        lienzo.toBlob((b) => (b ? resolve(b) : reject(new Error('No se pudo procesar la imagen.'))), 'image/jpeg', 0.82);
    });
}

// Sube la foto nueva y borra la anterior (si la hay). Regresa la ruta nueva.
export async function subirFotoEmpleado(empleadoId, blob, rutaAnterior) {
    const ruta = `empleado-${empleadoId}-${Date.now()}.jpg`;
    const { error } = await supabaseClient.storage.from(BUCKET).upload(ruta, blob, { contentType: 'image/jpeg', upsert: false });
    if (error) throw error;
    if (rutaAnterior) await borrarFoto(rutaAnterior);
    return ruta;
}

export async function borrarFoto(ruta) {
    if (!ruta) return;
    try { await supabaseClient.storage.from(BUCKET).remove([ruta]); } catch (_) { /* no bloquea: queda un archivo huérfano */ }
}

// Mapa ruta -> URL firmada, en UNA sola consulta.
export async function urlsFotos(rutas) {
    const unicas = [...new Set((rutas || []).filter(Boolean))];
    const mapa = new Map();
    if (!unicas.length) return mapa;
    try {
        const { data, error } = await supabaseClient.storage.from(BUCKET).createSignedUrls(unicas, VIGENCIA_URL_SEG);
        if (error) return mapa;
        (data || []).forEach((d) => { if (d.signedUrl) mapa.set(d.path, d.signedUrl); });
    } catch (_) { /* sin fotos: se usan las iniciales */ }
    return mapa;
}

export function iniciales(nombre) {
    const partes = String(nombre || '').trim().split(/\s+/).filter(Boolean);
    return ((partes[0]?.[0] || '') + (partes.length > 1 ? partes[partes.length - 1][0] : '')).toUpperCase() || '?';
}

// Círculo con la foto o, si no hay, con las iniciales.
export function avatarHtml(nombre, url, tam = 40) {
    const estilo = `width:${tam}px;height:${tam}px;min-width:${tam}px;`;
    if (url) {
        return `<img src="${esc(url)}" alt="${esc(nombre)}" class="rounded-full object-cover border border-slate-700" style="${estilo}">`;
    }
    return `<span class="rounded-full bg-slate-800 border border-slate-700 text-slate-300 font-semibold flex items-center justify-center" style="${estilo}font-size:${Math.round(tam * 0.36)}px">${esc(iniciales(nombre))}</span>`;
}
