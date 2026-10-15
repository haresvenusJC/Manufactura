// =====================================================================
//  Avisos con el diseño del tema: reemplaza el alert() del navegador
//  ("haresvenusjc.github.io says…") por un cuadro propio que toma la paleta
//  del tema activo (las clases slate/acento se remapean en tema-base.css).
//  Un solo lugar, sin tocar cada módulo: todos los alert('…') de la app lo usan.
//  - No bloquea el código (a diferencia del nativo): los avisos se encolan y se
//    muestran uno tras otro; Enter / Esc / clic en Aceptar cierran.
//  - Tono por el emoji del mensaje: ✅ éxito, ❌/⛔ error, ⚠ advertencia.
//  - confirm()/prompt() NO se reemplazan (necesitan responder de forma síncrona).
//  Para usar el nativo en un caso puntual: window.alertNativo('…').
// =====================================================================
const nativo = window.alert ? window.alert.bind(window) : null;
if (typeof document !== 'undefined' && !window.__dialogosTema) {
    window.__dialogosTema = true;
    window.alertNativo = nativo;
    const cola = [];
    let abierto = false;

    const tonoDe = (t) => {
        if (/^\s*(✅|✔|🎉)/.test(t)) return { cls: 'text-emerald-400', ico: '✅', titulo: 'Listo' };
        if (/^\s*(❌|⛔|🚫)/.test(t)) return { cls: 'text-rose-400', ico: '❌', titulo: 'No se pudo' };
        if (/^\s*(⚠|❗)/.test(t)) return { cls: 'text-amber-400', ico: '⚠️', titulo: 'Atención' };
        return { cls: 'text-sky-400', ico: 'ℹ️', titulo: 'Aviso' };
    };

    function mostrarSiguiente() {
        if (abierto || !cola.length) return;
        abierto = true;
        const texto = cola.shift();
        const tono = tonoDe(texto);
        // Quita el emoji inicial del cuerpo: ya va en el título.
        const cuerpo = texto.replace(/^\s*(✅|✔️?|🎉|❌|⛔|🚫|⚠️?|❗)\s*/, '');

        const ov = document.createElement('div');
        ov.setAttribute('data-no-movible', '');
        ov.className = 'fixed inset-0 bg-slate-950/40 flex items-center justify-center p-4';
        ov.style.zIndex = '2147483000';
        ov.innerHTML = `
          <div role="alertdialog" aria-modal="true" class="bg-slate-900 border border-slate-700 rounded-2xl shadow-2xl w-full max-w-md p-5">
            <h3 class="text-base font-bold ${tono.cls} mb-2"><span class="mr-1">${tono.ico}</span><span data-t></span></h3>
            <div data-c class="text-sm text-slate-200 whitespace-pre-line break-words max-h-[60vh] overflow-y-auto"></div>
            <div class="flex justify-end mt-5">
              <button type="button" data-ok class="bg-emerald-600 hover:bg-emerald-500 text-white font-semibold px-6 py-2 rounded-lg text-sm">Aceptar</button>
            </div>
          </div>`;
        ov.querySelector('[data-t]').textContent = tono.titulo;
        ov.querySelector('[data-c]').textContent = cuerpo;
        document.body.appendChild(ov);

        const cerrar = () => {
            document.removeEventListener('keydown', teclas, true);
            ov.remove();
            abierto = false;
            mostrarSiguiente();
        };
        const teclas = (e) => {
            if (e.key === 'Enter' || e.key === 'Escape') { e.preventDefault(); e.stopPropagation(); cerrar(); }
        };
        document.addEventListener('keydown', teclas, true);
        const ok = ov.querySelector('[data-ok]');
        ok.addEventListener('click', cerrar);
        ok.focus();
    }

    window.alert = (msg) => {
        if (!document.body) { if (nativo) nativo(msg); return; }
        cola.push(String(msg ?? ''));
        mostrarSiguiente();
    };
}
