// =====================================================================
//  Cargador con versión: evita que el navegador (sobre todo en el celular)
//  siga usando los .js viejos después de publicar cambios.
//
//  Uso en cada página:  <script src="cargador.js" data-entrada="js/app.js"></script>
//  Lee version.json SIN caché y arma un import map que pide cada módulo de js/
//  como  js/archivo.js?v=<version> ; con la misma versión el navegador reutiliza
//  su copia, con una versión nueva descarga todo de nuevo.
//  version.json se regenera en cada cambio a js/ con:  python3 actualizar-version.py
//  Si version.json no carga, usa la hora actual (descarga todo, nunca se queda viejo).
// =====================================================================
(function () {
    var actual = document.currentScript;
    var entrada = actual.getAttribute('data-entrada');
    function arrancar(v, modulos) {
        var mapa = { imports: {} };
        (modulos || []).forEach(function (m) { mapa.imports['./js/' + m] = './js/' + m + '?v=' + v; });
        var im = document.createElement('script');
        im.type = 'importmap';
        im.textContent = JSON.stringify(mapa);
        document.head.appendChild(im);
        var s = document.createElement('script');
        s.type = 'module';
        s.src = entrada + '?v=' + v;
        document.body.appendChild(s);
    }
    fetch('version.json', { cache: 'no-store' })
        .then(function (r) { return r.json(); })
        .then(function (d) { arrancar(d.v || String(Date.now()), d.modulos); })
        .catch(function () { arrancar(String(Date.now()), []); });
})();
