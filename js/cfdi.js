// =====================================================================
// Lector de CFDI (XML) — extrae encabezado, impuestos y conceptos.
// Compatible con CFDI 3.3 y 4.0 (se navega por localName, sin namespaces).
// =====================================================================

export function parsearCfdi(text) {
    let dom;
    try {
        dom = new DOMParser().parseFromString(text, 'application/xml');
        if (dom.getElementsByTagName('parsererror').length) throw new Error('XML mal formado');
    } catch (e) {
        return { error: 'No se pudo leer el XML: ' + (e.message || e) };
    }

    const all = [...dom.getElementsByTagName('*')];
    const byLocal = (name) => all.filter((el) => el.localName === name);
    const comp = byLocal('Comprobante')[0];
    if (!comp) return { error: 'El archivo no parece un CFDI (falta el nodo Comprobante).' };

    const A = (el, n) => (el && el.getAttribute(n)) || '';
    const toNum = (v) => { const x = parseFloat(v); return Number.isFinite(x) ? x : 0; };
    const r2 = (n) => Math.round((Number(n) || 0) * 100) / 100;

    let iva = 0, ieps = 0, retIva = 0, retIsr = 0;
    const impComp = [...comp.children].find((c) => c.localName === 'Impuestos');
    if (impComp) {
        [...impComp.getElementsByTagName('*')].forEach((nodo) => {
            const v = toNum(A(nodo, 'Importe'));
            if (nodo.localName === 'Traslado') {
                if (A(nodo, 'Impuesto') === '002') iva += v;
                else if (A(nodo, 'Impuesto') === '003') ieps += v;
            } else if (nodo.localName === 'Retencion') {
                if (A(nodo, 'Impuesto') === '002') retIva += v;
                else if (A(nodo, 'Impuesto') === '001') retIsr += v;
            }
        });
    }

    const emisor = byLocal('Emisor')[0];

    return {
        fecha: A(comp, 'Fecha').slice(0, 10),
        folio: [A(comp, 'Serie'), A(comp, 'Folio')].filter(Boolean).join('-'),
        subtotal: r2(toNum(A(comp, 'SubTotal'))),
        descuento: r2(toNum(A(comp, 'Descuento'))),
        total: r2(toNum(A(comp, 'Total'))),
        iva: r2(iva), ieps: r2(ieps), retIva: r2(retIva), retIsr: r2(retIsr),
        moneda: (A(comp, 'Moneda') || 'MXN').toUpperCase(),
        tipoCambio: toNum(A(comp, 'TipoCambio')) || 1,
        formaPago: A(comp, 'FormaPago'),
        metodoPago: A(comp, 'MetodoPago'),
        tipoComprobante: A(comp, 'TipoDeComprobante'),
        lugarExpedicion: A(comp, 'LugarExpedicion'),
        rfcEmisor: A(emisor, 'Rfc').toUpperCase(),
        nombreEmisor: A(emisor, 'Nombre'),
        regimenEmisor: A(emisor, 'RegimenFiscal'),
        usoCfdi: A(byLocal('Receptor')[0], 'UsoCFDI'),
        uuid: A(byLocal('TimbreFiscalDigital')[0], 'UUID'),
        conceptos: byLocal('Concepto').map((c) => ({
            claveSat: A(c, 'ClaveProdServ').trim(),
            noId: A(c, 'NoIdentificacion').trim(),
            cantidad: toNum(A(c, 'Cantidad')),
            valorUnitario: toNum(A(c, 'ValorUnitario')),
            importe: toNum(A(c, 'Importe')),
            descripcion: A(c, 'Descripcion'),
        })),
    };
}

// c_forma_pago del SAT -> lista simple (efectivo / transferencia / tarjeta / cheque)
export function formaPagoSimple(clave) {
    return ({ '01': 'efectivo', '02': 'cheque', '03': 'transferencia', '04': 'tarjeta', '28': 'tarjeta' }[clave]) || '';
}

// =====================================================================
// Lector de CFDI (PDF) — cuando no se tiene el XML, mejor esfuerzo sobre
// la representación impresa. El PDF no tiene etiquetas como el XML: se
// extrae el texto por posición (para no perder las columnas de la tabla
// de conceptos) y se buscan los datos por patrones. Es MENOS confiable
// que parsearCfdi — siempre revisa lo que se precargó antes de confirmar.
// =====================================================================

// Extrae el texto de un PDF agrupando por renglón (misma coordenada Y),
// para conservar la estructura de columnas al concatenar el texto.
export async function extraerTextoPdf(archivo) {
    if (!window.pdfjsLib) throw new Error('No se pudo cargar la librería de lectura de PDF (revisa tu conexión y recarga la página).');

    const buffer = await archivo.arrayBuffer();
    const pdf = await pdfjsLib.getDocument({ data: buffer }).promise;
    let textoCompleto = '';

    for (let n = 1; n <= pdf.numPages; n++) {
        const page = await pdf.getPage(n);
        const contenido = await page.getTextContent();
        const porY = new Map();
        contenido.items.forEach((item) => {
            const y = Math.round(item.transform[5]);
            if (!porY.has(y)) porY.set(y, []);
            porY.get(y).push(item.str);
        });
        [...porY.keys()].sort((a, b) => b - a).forEach((y) => {
            textoCompleto += porY.get(y).join(' ') + '\n';
        });
    }
    return textoCompleto;
}

// texto -> mismo "shape" que parsearCfdi(), + avisos[] con lo que no se
// pudo leer con confianza (para mostrarlo al usuario, nunca inventar).
export function parsearCfdiPdf(texto) {
    const avisos = [];
    const t = String(texto || '');
    const num = (s) => { const x = parseFloat(String(s || '').replace(/,/g, '')); return Number.isFinite(x) ? x : 0; };
    const r2 = (n) => Math.round((Number(n) || 0) * 100) / 100;

    const mUuid = t.match(/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}/);
    const uuid = mUuid ? mUuid[0].toUpperCase() : '';
    if (!uuid) avisos.push('No se encontró el Folio Fiscal (UUID) en el PDF.');

    // RFC: el emisor normalmente aparece antes que "Receptor" en la
    // representación impresa. Si no se detecta esa palabra, se toma el
    // primer RFC del documento.
    const reRfc = /\b([A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3})\b/g;
    const corte = t.search(/Receptor/i);
    const bloqueEmisor = corte > 0 ? t.slice(0, corte) : t;
    let rfcEmisor = '';
    let m;
    while ((m = reRfc.exec(bloqueEmisor)) !== null) { rfcEmisor = m[1].toUpperCase(); break; }
    if (!rfcEmisor) {
        reRfc.lastIndex = 0;
        const m2 = reRfc.exec(t);
        if (m2) rfcEmisor = m2[1].toUpperCase();
    }
    if (!rfcEmisor) avisos.push('No se encontró el RFC del emisor.');

    let fecha = '';
    const mIso = t.match(/(\d{4}-\d{2}-\d{2})T\d{2}:\d{2}:\d{2}/);
    if (mIso) fecha = mIso[1];
    if (!fecha) {
        const mDmy = t.match(/Fecha[^\n]{0,30}?(\d{2})[\/\-](\d{2})[\/\-](\d{4})/i);
        if (mDmy) fecha = `${mDmy[3]}-${mDmy[2]}-${mDmy[1]}`;
    }
    if (!fecha) avisos.push('No se encontró la fecha de emisión — captúrala a mano.');

    let folio = '';
    const mFolio = t.match(/\bFolio\b(?!\s*Fiscal)[:\s]*([A-Za-z0-9\-]{1,20})/i);
    if (mFolio) folio = mFolio[1];
    const mSerie = t.match(/\bSerie\b[:\s]*([A-Za-z0-9\-]{1,10})/i);
    if (mSerie && folio) folio = `${mSerie[1]}-${folio}`;

    const mMoneda = t.match(/Moneda[:\s]*([A-Z]{3})\b/i);
    const moneda = mMoneda ? mMoneda[1].toUpperCase() : 'MXN';

    const mMetodo = /\bPPD\b/.test(t) ? 'PPD' : (/\bPUE\b/.test(t) ? 'PUE' : '');

    let subtotal = 0;
    const mSub = t.match(/Subtotal[:\s]*\$?\s*([\d,]+\.\d{2})/i);
    if (mSub) subtotal = num(mSub[1]);

    let total = 0;
    const totales = [...t.matchAll(/\bTotal\b[:\s]*\$?\s*([\d,]+\.\d{2})/gi)];
    if (totales.length) total = num(totales[totales.length - 1][1]);
    if (!total) avisos.push('No se encontró el Total — verifica los importes con la factura.');

    let iva = 0;
    const mIvaTot = t.match(/Total\s+de\s+impuestos\s+traslad[ao]dos[:\s]*\$?\s*([\d,]+\.\d{2})/i);
    if (mIvaTot) {
        iva = num(mIvaTot[1]);
    } else {
        const ivas = [...t.matchAll(/I\.?V\.?A\.?[^\n]{0,15}?([\d,]+\.\d{2})/gi)];
        if (ivas.length) iva = num(ivas[ivas.length - 1][1]);
    }
    if (subtotal && total && !iva) {
        // último recurso: lo que no es subtotal ni cuadra con IEPS/retenciones.
        const dif = r2(total - subtotal);
        if (dif > 0 && dif < subtotal) { iva = dif; avisos.push('El IVA se infirió de Total − Subtotal — confírmalo contra la factura.'); }
    }
    if (!subtotal || !total) avisos.push('No se encontraron Subtotal y/o Total con certeza — revísalos contra la factura.');

    // ---- Tabla de conceptos: mejor esfuerzo por posición de renglón ----
    const conceptos = [];
    const lineas = t.split('\n');
    const iHeader = lineas.findIndex((l) => /cantidad/i.test(l) && /(descripci|unitario)/i.test(l));
    if (iHeader >= 0) {
        let iFin = lineas.findIndex((l, i) => i > iHeader && /subtotal/i.test(l));
        if (iFin < 0) iFin = lineas.length;
        for (let i = iHeader + 1; i < iFin; i++) {
            const linea = lineas[i].trim();
            if (!linea) continue;
            const montos = [...linea.matchAll(/\d{1,3}(?:,\d{3})*\.\d{2,6}/g)];
            if (montos.length < 2) continue;   // sin valor unitario + importe, no se puede armar la fila
            const importe = num(montos[montos.length - 1][0]);
            const valorUnitario = num(montos[montos.length - 2][0]);
            const mCant = linea.match(/^\s*(\d+(?:\.\d+)?)\b/);
            const cantidad = mCant ? num(mCant[1]) : (valorUnitario ? r2(importe / valorUnitario) : 0);
            const mClave = linea.match(/\b(\d{8})\b/);
            let descripcion = linea
                .replace(mCant ? mCant[0] : '', '')
                .replace(mClave ? mClave[0] : '', '');
            montos.forEach((mo) => { descripcion = descripcion.replace(mo[0], ''); });
            descripcion = descripcion.replace(/\s{2,}/g, ' ').trim();
            if (cantidad > 0 && importe > 0) {
                conceptos.push({ claveSat: mClave ? mClave[1] : '', noId: '', cantidad, valorUnitario, importe, descripcion: descripcion || '(descripción no legible)' });
            }
        }
    }
    if (!conceptos.length) avisos.push('No se pudieron leer las partidas de la factura desde el PDF — agrégalas a mano, o usa el XML si lo tienes.');

    return {
        fecha, folio, subtotal: r2(subtotal), descuento: 0, total: r2(total),
        iva: r2(iva), ieps: 0, retIva: 0, retIsr: 0,
        moneda, tipoCambio: 1, formaPago: '', metodoPago: mMetodo,
        tipoComprobante: 'I', lugarExpedicion: '',
        rfcEmisor, nombreEmisor: '', regimenEmisor: '', usoCfdi: '',
        uuid, conceptos, avisos, origenPdf: true,
    };
}
