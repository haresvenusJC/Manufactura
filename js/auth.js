import { supabaseClient } from './supabase.js';

// Puerta de autenticación de la app de administración.
// Los empleados NUNCA pasan por aquí: usan la página móvil (orden-trabajo.html)
// de forma anónima. Solo el/los admin inician sesión, y con eso el rol pasa a
// 'authenticated', que es lo que las políticas RLS usan para dejar ver costos.

export async function getSesion() {
    const { data } = await supabaseClient.auth.getSession();
    return data?.session || null;
}

export async function iniciarSesion(email, password) {
    const { data, error } = await supabaseClient.auth.signInWithPassword({
        email: String(email || '').trim(),
        password: String(password || '')
    });
    if (error) throw error;
    registrarEventoSesion('LOGIN');
    return data.session;
}

export async function cerrarSesion() {
    await registrarEventoSesion('LOGOUT');   // antes de cerrar: necesita la sesión para saber quién es
    await supabaseClient.auth.signOut();
}

// Deja en la bitácora que este usuario entró / salió. Nunca estorba: si la migración
// sql/2026-10-20_bitacora_todos_los_movimientos.sql aún no está, simplemente no registra.
async function registrarEventoSesion(accion) {
    try { await supabaseClient.rpc('bitacora_evento', { p_accion: accion }); } catch (_) { /* sin bitácora de sesión */ }
}

export function alCambiarSesion(callback) {
    supabaseClient.auth.onAuthStateChange((_evento, session) => callback(session));
}

/**
 * Muestra/oculta el overlay de login y engancha el formulario.
 * @param {() => void} onLogin  se llama cuando ya hay sesión válida.
 */
export function montarLogin(onLogin) {
    const overlay = document.getElementById('loginOverlay');
    const form = document.getElementById('formLogin');
    const errorEl = document.getElementById('loginError');
    const btn = document.getElementById('btnLogin');
    if (!overlay || !form) return;

    let sesionActiva = false;

    const mostrar = () => overlay.classList.remove('hidden');
    const ocultar = () => overlay.classList.add('hidden');

    form.onsubmit = async (e) => {
        e.preventDefault();
        errorEl.textContent = '';
        btn.disabled = true;
        btn.textContent = 'Entrando...';
        try {
            await iniciarSesion(
                document.getElementById('loginEmail').value,
                document.getElementById('loginPassword').value
            );
            // onAuthStateChange se encarga del resto.
        } catch (err) {
            errorEl.textContent = err.message || 'No se pudo iniciar sesión.';
        } finally {
            btn.disabled = false;
            btn.textContent = 'Entrar';
        }
    };

    alCambiarSesion((session) => {
        if (session && !sesionActiva) {
            sesionActiva = true;
            ocultar();
            onLogin();
        } else if (!session && sesionActiva) {
            // Cierre de sesión: recargar para dejar la app en blanco.
            location.reload();
        }
    });

    getSesion().then((session) => {
        if (session) {
            sesionActiva = true;
            ocultar();
            onLogin();
        } else {
            mostrar();
        }
    });
}
