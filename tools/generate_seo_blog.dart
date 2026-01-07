// SEO Blog Generator Script
// Run with: dart run tools/generate_seo_blog.dart
// Generates static HTML pages from blog articles for SEO

import 'dart:io';

// Article data extracted from initial_articles.dart
final List<Map<String, dynamic>> articles = [
  {
    'id': 'seed-001',
    'slug': 'como-abrir-negocio-panama',
    'title': 'Cómo abrir un negocio formal en Panamá paso a paso',
    'description': 'Pasos para abrir tu empresa en Panamá: Aviso de Operación, RUC, Municipio y bancos. Guía práctica y legal.',
    'category': 'Legal & Trámites',
    'imageUrl': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c',
    'metaTitle': 'Cómo abrir un negocio en Panamá: Guía 2024',
    'metaDescription': 'Pasos para abrir tu empresa en Panamá: Aviso de Operación, RUC, Municipio y bancos. Guía práctica y legal.',
    'keywords': ['aviso de operación', 'panama emprende', 'ruc', 'legal', 'sociedad anónima'],
    'content': '''
<h2>Introducción</h2>
<p>Iniciar un negocio en Panamá es una aventura emocionante, pero la burocracia puede parecer abrumadora al principio. Muchos emprendedores operan en la informalidad por miedo a los trámites, pero formalizarse te abre puertas a créditos bancarios, contratos con el Estado y mayor confianza de tus clientes.</p>
<p>En esta guía, te explicamos paso a paso cómo constituir tu empresa y sacar tu Aviso de Operación sin perder la cabeza en el intento.</p>

<h2>1. Define tu Figura Legal</h2>
<p>Lo primero es decidir si operarás como <strong>Persona Natural</strong> o <strong>Persona Jurídica</strong>.</p>

<h3>Persona Natural (tú mismo)</h3>
<ul>
<li><strong>Ventajas:</strong> Rápido, barato, sin gastos de abogados para constituir sociedad.</li>
<li><strong>Desventajas:</strong> Tu patrimonio personal responde por las deudas del negocio.</li>
<li><strong>Ideal para:</strong> Freelancers, pequeños comercios familiares.</li>
</ul>

<h3>Persona Jurídica (Sociedad Anónima o S. de R.L.)</h3>
<ul>
<li><strong>Ventajas:</strong> Protege tu patrimonio personal. Da una imagen más corporativa.</li>
<li><strong>Desventajas:</strong> Requiere abogado, pago de Tasa Única anual (\$300).</li>
<li><strong>Ideal para:</strong> Startups, negocios con socios, empresas que buscarán inversión.</li>
</ul>

<h2>2. El Aviso de Operación</h2>
<p>El Aviso de Operación es la licencia que te permite realizar actividades comerciales.</p>
<ul>
<li><strong>¿Dónde se hace?</strong> En el portal <a href="https://www.panamaemprende.gob.pa" target="_blank">PanamaEmprende</a>.</li>
<li><strong>Costo:</strong> Desde \$15 para persona natural y \$55 para jurídica.</li>
<li><strong>Requisito:</strong> Tener tu cédula o pasaporte vigente y los datos de la sociedad (si aplica).</li>
</ul>

<h2>3. Inscripción en el Municipio</h2>
<p>Una vez tienes tu Aviso, debes inscribirte en el Municipio de tu distrito.</p>

<h2>4. La DGI y el RUC</h2>
<p>Tu número de RUC es tu identificación fiscal. Debes registrarte en el sistema e-Tax 2.0 para declarar tus impuestos.</p>

<h2>5. Cuenta Bancaria</h2>
<p>No mezcles tus finanzas. Abre una cuenta comercial.</p>

<h2>Tips Finales</h2>
<ul>
<li>Guarda copia de todo.</li>
<li>Contrata a un contador desde el día 1.</li>
<li>No olvides pagar tu Tasa Única si tienes sociedad.</li>
</ul>
<p><strong>¡Formalizarse es el primer paso para crecer en grande!</strong></p>
'''
  },
  {
    'id': 'seed-002',
    'slug': 'guia-itbms-impuestos-panama',
    'title': 'Guía básica del ITBMS y impuestos para emprendedores',
    'description': 'Aprende cuándo cobrar ITBMS, cómo pagar la renta y evitar multas de la DGI en tu negocio.',
    'category': 'Contabilidad & Finanzas',
    'imageUrl': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c',
    'metaTitle': 'Guía de ITBMS e Impuestos Panamá',
    'metaDescription': 'Aprende cuándo cobrar ITBMS, cómo pagar la renta y evitar multas de la DGI en tu negocio.',
    'keywords': ['itbms', 'impuestos', 'dgi', 'renta', 'contabilidad'],
    'content': '''
<h2>Introducción</h2>
<p>El tema impositivo es quizás el que más miedo da a los nuevos empresarios. ¿Qué es el 7%? ¿Cuándo debo cobrarlo?</p>

<h2>1. ITBMS (Impuesto de Transferencia de Bienes Muebles y Servicios)</h2>
<p>Es el impuesto al consumo, generalmente del 7%.</p>
<h3>¿Quiénes deben cobrarlo?</h3>
<p>Si tus ingresos brutos anuales superan los <strong>\$36,000</strong>, es OBLIGATORIO registrarte como contribuyente de ITBMS.</p>

<h2>2. Impuesto Sobre la Renta (ISR)</h2>
<p>Es el impuesto sobre tus ganancias netas (Ingresos - Gastos Deducibles). Se declara anualmente.</p>

<h2>3. Impuesto Municipal</h2>
<p>Se paga al municipio donde operas. Es un gasto deducible de tu ISR.</p>

<h2>Errores Comunes</h2>
<ul>
<li><strong>Gastar el ITBMS:</strong> El dinero del 7% NO es tuyo. Guárdalo aparte.</li>
<li><strong>No pedir facturas:</strong> Si no tienes factura fiscal, no puedes deducir ese gasto.</li>
</ul>
'''
  },
  {
    'id': 'seed-003',
    'slug': 'como-fijar-precios-correctamente',
    'title': 'Cómo fijar precios correctamente para ganar dinero',
    'description': 'Aprende la fórmula para fijar precios ganadores, diferenciar margen de mark-up y calcular tu punto de equilibrio.',
    'category': 'Gestión Empresarial',
    'imageUrl': 'https://images.unsplash.com/photo-1591696205602-2f950c417cb9',
    'metaTitle': 'Cómo fijar precios y márgenes correctos',
    'metaDescription': 'Aprende la fórmula para fijar precios ganadores y calcular tu punto de equilibrio.',
    'keywords': ['precios', 'costos', 'margen', 'ganancia', 'punto equilibrio'],
    'content': '''
<h2>Introducción</h2>
<p>¿Pones precios mirando a la competencia o multiplicando por 2? Es uno de los errores más graves.</p>

<h2>1. La Diferencia entre Costo, Precio y Valor</h2>
<ul>
<li><strong>Costo:</strong> Lo que te cuesta producir el producto.</li>
<li><strong>Precio:</strong> Lo que cobras al cliente.</li>
<li><strong>Valor:</strong> Lo que el cliente PERCIBE que vale tu producto.</li>
</ul>

<h2>2. Fórmula de Precio</h2>
<p><code>Precio = Costo / (1 - %Margen Deseado)</code></p>
<p>Ejemplo: Quieres ganar 30% de margen sobre algo que cuesta \$70. 70 / 0.70 = <strong>\$100</strong></p>

<h2>3. Punto de Equilibrio</h2>
<p><code>PE = Costos Fijos Totales / (Precio Venta - Costo Variable Unitario)</code></p>
'''
  },
  {
    'id': 'seed-004',
    'slug': 'como-llevar-primera-planilla',
    'title': 'Cómo llevar tu primera planilla sin volverte loco',
    'description': 'Aprende a calcular salario neto, seguro social, educativo y décimo tercer mes para tus empleados.',
    'category': 'Recursos Humanos',
    'imageUrl': 'https://images.unsplash.com/photo-1521791136064-7986c2920216',
    'metaTitle': 'Guía de Planilla y CSS en Panamá',
    'metaDescription': 'Aprende a calcular salario neto, seguro social, educativo y décimo tercer mes.',
    'keywords': ['planilla', 'css', 'sipe', 'salario', 'prestaciones'],
    'content': '''
<h2>Introducción</h2>
<p>Contrataste a alguien. ¡Felicidades! Ahora eres responsable de retener y pagar sus prestaciones.</p>

<h2>Descuentos al Empleado</h2>
<ul>
<li><strong>Seguro Social (CSS):</strong> 9.75%</li>
<li><strong>Seguro Educativo:</strong> 1.25%</li>
<li><strong>ISR:</strong> Solo si gana más de \$11,000 al año</li>
</ul>

<h2>Aportes del Patrono</h2>
<ul>
<li><strong>Seguro Social Patronal:</strong> 12.25%</li>
<li><strong>Seguro Educativo Patronal:</strong> 1.50%</li>
<li><strong>Riesgos Profesionales:</strong> ~0.98% - 5.67%</li>
</ul>

<h2>Prestaciones</h2>
<ul>
<li><strong>Décimo Tercer Mes:</strong> Provisión mensual: 8.33%</li>
<li><strong>Vacaciones:</strong> Provisión mensual: 9.09%</li>
<li><strong>Prima de Antigüedad:</strong> Provisión: 1.92%</li>
</ul>
'''
  },
  {
    'id': 'seed-005',
    'slug': 'errores-comunes-dinero-negocio',
    'title': '7 errores comunes al manejar el dinero de tu negocio',
    'description': 'Evita mezclar finanzas personales, dar crédito excesivo y otros errores que quiebran negocios.',
    'category': 'Finanzas',
    'imageUrl': 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e',
    'metaTitle': '7 Errores Financieros Comunes',
    'metaDescription': 'Evita los errores que quiebran negocios rentables.',
    'keywords': ['errores financieros', 'flujo de caja', 'dinero', 'quiebra'],
    'content': '''
<h2>1. Caja Chica Personal</h2>
<p>Usar la cuenta del negocio para gastos personales. <strong>Solución:</strong> Ponte un sueldo fijo.</p>

<h2>2. No conocer tu Margen Real</h2>
<p><strong>Solución:</strong> Revisa tu estructura de costos trimestralmente.</p>

<h2>3. Mal Manejo del Crédito</h2>
<p><strong>Solución:</strong> Negocia plazos con proveedores que calcen con tus cobros.</p>

<h2>4. Inventario Estancado</h2>
<p><strong>Solución:</strong> Remata lo viejo, libera cash.</p>

<h2>5. Ignorar los Impuestos</h2>
<p><strong>Solución:</strong> Cuenta de ahorro separada para impuestos.</p>

<h2>6. Crecer muy rápido sin capital</h2>
<p><strong>Solución:</strong> Planifica tu flujo de caja antes de aceptar grandes contratos.</p>

<h2>7. No tener Fondo de Emergencia</h2>
<p><strong>Solución:</strong> Intenta guardar 3 meses de gastos fijos.</p>
'''
  },
  {
    'id': 'seed-006',
    'slug': 'marketing-digital-pequenos-negocios',
    'title': 'Introducción al marketing digital para pequeños negocios',
    'description': 'Estrategias sencillas de marketing digital, redes sociales y embudos de venta.',
    'category': 'Marketing & Ventas',
    'imageUrl': 'https://images.unsplash.com/photo-1432888498266-38ffec3eaf0a',
    'metaTitle': 'Marketing Digital Básico para Pymes',
    'metaDescription': 'Estrategias sencillas de marketing digital para pequeños negocios.',
    'keywords': ['marketing digital', 'redes sociales', 'ventas', 'instagram'],
    'content': '''
<h2>1. Conoce a tu Cliente Ideal</h2>
<p>No puedes venderle a "todo el mundo". Define su edad, qué le preocupa, qué red social usa.</p>

<h2>2. El Embudo Básico (AIDA)</h2>
<ul>
<li><strong>Atención:</strong> Que te vean (Reels, Ads, SEO)</li>
<li><strong>Interés:</strong> Que les guste lo que ven</li>
<li><strong>Deseo:</strong> Que quieran tu solución</li>
<li><strong>Acción:</strong> Que compren</li>
</ul>

<h2>3. Google My Business</h2>
<p>Si tienes local físico, esto es OBLIGATORIO. Es gratis y apareces en Google Maps.</p>

<h2>4. Publicidad Pagada</h2>
<p>El alcance orgánico es bajo. Invierte \$5-10 en pauta bien segmentada.</p>
'''
  },
];

// Template HTML para cada artículo
String generateArticlePage(Map<String, dynamic> article) {
  final keywords = (article['keywords'] as List).join(', ');
  
  // Generate related articles sidebar (exclude current article)
  final relatedArticles = articles.where((a) => a['id'] != article['id']).take(5).toList();
  final sidebarHtml = relatedArticles.map((a) => '''
        <a href="${a['slug']}.html" class="sidebar-article">
            <img src="${a['imageUrl']}" alt="${a['title']}">
            <div>
                <span class="sidebar-category">${a['category']}</span>
                <h4>${a['title']}</h4>
            </div>
        </a>
  ''').join('\n');
  
  return '''<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${article['metaTitle']} | Empodérate Blog</title>
    <meta name="description" content="${article['metaDescription']}">
    <meta name="keywords" content="$keywords">
    <meta name="author" content="Empodérate">
    <meta name="robots" content="index, follow">
    
    <!-- Open Graph -->
    <meta property="og:title" content="${article['metaTitle']}">
    <meta property="og:description" content="${article['metaDescription']}">
    <meta property="og:image" content="${article['imageUrl']}">
    <meta property="og:type" content="article">
    <meta property="og:site_name" content="Empodérate">
    
    <!-- Twitter Card -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="${article['metaTitle']}">
    <meta name="twitter:description" content="${article['metaDescription']}">
    <meta name="twitter:image" content="${article['imageUrl']}">
    
    <!-- Schema.org Article -->
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "Article",
        "headline": "${article['title']}",
        "description": "${article['description']}",
        "image": "${article['imageUrl']}",
        "author": {
            "@type": "Organization",
            "name": "Empodérate"
        },
        "publisher": {
            "@type": "Organization",
            "name": "Empodérate",
            "logo": {
                "@type": "ImageObject",
                "url": "/icons/Icon-192.png"
            }
        }
    }
    </script>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, #001220 0%, #0a1628 100%);
            color: #e0e0e0;
            min-height: 100vh;
            line-height: 1.7;
        }
        header {
            background: rgba(0, 12, 32, 0.95);
            border-bottom: 1px solid rgba(0, 229, 255, 0.2);
            padding: 16px 24px;
            position: sticky;
            top: 0;
            z-index: 100;
            backdrop-filter: blur(10px);
        }
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo {
            font-size: 24px;
            font-weight: 700;
            color: #00E5FF;
            text-decoration: none;
            text-shadow: 0 0 20px rgba(0, 229, 255, 0.5);
        }
        .cta-button {
            background: linear-gradient(135deg, #D4AF37, #F4D35E);
            color: #001220;
            padding: 10px 24px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .cta-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(212, 175, 55, 0.4);
        }
        .hero {
            height: 300px;
            background: url('${article['imageUrl']}') center/cover;
            position: relative;
        }
        .hero::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(to bottom, transparent 0%, #001220 100%);
        }
        .hero-content {
            position: absolute;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            width: 100%;
            max-width: 1200px;
            padding: 0 24px;
            z-index: 10;
        }
        .category {
            display: inline-block;
            background: rgba(212, 175, 55, 0.2);
            border: 1px solid rgba(212, 175, 55, 0.5);
            color: #D4AF37;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 12px;
        }
        h1 {
            font-size: 32px;
            color: #fff;
            text-shadow: 0 2px 20px rgba(0,0,0,0.5);
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 24px;
            display: grid;
            grid-template-columns: 1fr 320px;
            gap: 40px;
        }
        main {
            min-width: 0;
        }
        article h2 {
            color: #00E5FF;
            margin: 32px 0 16px;
            font-size: 24px;
        }
        article h3 {
            color: #D4AF37;
            margin: 24px 0 12px;
            font-size: 18px;
        }
        article p {
            margin-bottom: 16px;
            color: #c0c0c0;
        }
        article ul, article ol {
            margin: 16px 0;
            padding-left: 24px;
        }
        article li {
            margin-bottom: 8px;
            color: #c0c0c0;
        }
        article strong {
            color: #fff;
        }
        article code {
            background: rgba(0, 229, 255, 0.1);
            border: 1px solid rgba(0, 229, 255, 0.3);
            padding: 2px 8px;
            border-radius: 4px;
            font-family: monospace;
            color: #00E5FF;
        }
        article a {
            color: #00E5FF;
            text-decoration: underline;
        }
        .cta-box {
            background: linear-gradient(135deg, rgba(212, 175, 55, 0.1), rgba(244, 211, 94, 0.1));
            border: 2px solid #D4AF37;
            border-radius: 16px;
            padding: 32px;
            text-align: center;
            margin: 48px 0;
        }
        .cta-box h3 {
            color: #D4AF37;
            margin-bottom: 12px;
        }
        .cta-box p {
            margin-bottom: 20px;
        }
        aside {
            position: sticky;
            top: 100px;
            align-self: start;
        }
        .sidebar-title {
            color: #00E5FF;
            font-size: 18px;
            margin-bottom: 16px;
            font-weight: 600;
        }
        .sidebar-article {
            display: flex;
            gap: 12px;
            padding: 12px;
            background: #151C2B;
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.05);
            margin-bottom: 12px;
            text-decoration: none;
            transition: all 0.3s;
        }
        .sidebar-article:hover {
            border-color: #D4AF37;
            transform: translateX(4px);
        }
        .sidebar-article img {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border-radius: 8px;
        }
        .sidebar-article div {
            flex: 1;
            min-width: 0;
        }
        .sidebar-category {
            display: inline-block;
            background: rgba(212, 175, 55, 0.15);
            color: #D4AF37;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 9px;
            font-weight: 600;
            margin-bottom: 6px;
        }
        .sidebar-article h4 {
            color: #fff;
            font-size: 13px;
            line-height: 1.3;
            margin: 0;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        footer {
            background: rgba(0, 12, 32, 0.95);
            border-top: 1px solid rgba(0, 229, 255, 0.2);
            padding: 32px 24px;
            text-align: center;
            color: #888;
        }
        footer a {
            color: #00E5FF;
            text-decoration: none;
        }
        @media (max-width: 900px) {
            .container {
                grid-template-columns: 1fr;
            }
            aside {
                position: static;
            }
        }
        @media (max-width: 600px) {
            h1 { font-size: 24px; }
            .hero { height: 220px; }
        }
    </style>
</head>
<body>
    <header>
        <div class="header-content">
            <a href="/" class="logo">EMPODÉRATE</a>
            <a href="/" class="cta-button">🚀 Usar App Gratis</a>
        </div>
    </header>
    
    <div class="hero">
        <div class="hero-content">
            <span class="category">${article['category']}</span>
            <h1>${article['title']}</h1>
        </div>
    </div>
    
    <div class="container">
        <main>
            <article>
                ${article['content']}
            </article>
            
            <div class="cta-box">
                <h3>📱 ¿Te fue útil este artículo?</h3>
                <p>Empodérate tiene herramientas gratuitas para ayudarte a gestionar tu negocio: calculadoras, chatbot con IA, checklist de trámites y más.</p>
                <a href="../index.html" class="cta-button">Probar Empodérate Gratis →</a>
            </div>
        </main>
        
        <aside>
            <h3 class="sidebar-title">📚 Más Artículos</h3>
            $sidebarHtml
            <a href="index.html" class="cta-button" style="display: block; text-align: center; margin-top: 20px;">Ver Todos →</a>
        </aside>
    </div>
    
    <footer>
        <p>© 2024 Empodérate · <a href="../index.html">Ir a la App</a> · <a href="index.html">Ver más artículos</a></p>
    </footer>
</body>
</html>
''';
}


// Genera el index del blog
String generateBlogIndex() {
  final articleCards = articles.map((a) => '''
        <a href="${a['slug']}.html" class="article-card">
            <img src="${a['imageUrl']}" alt="${a['title']}">
            <div class="card-content">
                <span class="category">${a['category']}</span>
                <h3>${a['title']}</h3>
                <p>${a['description']}</p>
            </div>
        </a>
''').join('\n');

  return '''<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blog Empresarial | Empodérate</title>
    <meta name="description" content="Artículos, guías y consejos para emprendedores en Panamá. Aprende sobre trámites, finanzas, planilla, marketing y más.">
    <meta name="robots" content="index, follow">
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, #001220 0%, #0a1628 100%);
            color: #e0e0e0;
            min-height: 100vh;
        }
        header {
            background: rgba(0, 12, 32, 0.95);
            border-bottom: 1px solid rgba(0, 229, 255, 0.2);
            padding: 16px 24px;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo {
            font-size: 24px;
            font-weight: 700;
            color: #00E5FF;
            text-decoration: none;
        }
        .cta-button {
            background: linear-gradient(135deg, #D4AF37, #F4D35E);
            color: #001220;
            padding: 10px 24px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
        }
        main {
            max-width: 1200px;
            margin: 0 auto;
            padding: 48px 24px;
        }
        h1 {
            color: #00E5FF;
            font-size: 36px;
            margin-bottom: 12px;
            text-shadow: 0 0 30px rgba(0, 229, 255, 0.3);
        }
        .subtitle {
            color: #888;
            margin-bottom: 40px;
        }
        .articles-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 24px;
        }
        .article-card {
            background: #151C2B;
            border-radius: 16px;
            overflow: hidden;
            text-decoration: none;
            border: 1px solid rgba(255,255,255,0.05);
            transition: transform 0.3s, border-color 0.3s;
        }
        .article-card:hover {
            transform: translateY(-4px);
            border-color: #D4AF37;
        }
        .article-card img {
            width: 100%;
            height: 180px;
            object-fit: cover;
        }
        .card-content {
            padding: 20px;
        }
        .category {
            display: inline-block;
            background: rgba(212, 175, 55, 0.2);
            color: #D4AF37;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            margin-bottom: 12px;
        }
        .article-card h3 {
            color: #fff;
            font-size: 18px;
            margin-bottom: 8px;
        }
        .article-card p {
            color: #888;
            font-size: 14px;
            line-height: 1.5;
        }
        footer {
            text-align: center;
            padding: 32px;
            color: #666;
            border-top: 1px solid rgba(255,255,255,0.05);
        }
    </style>
</head>
<body>
    <header>
        <div class="header-content">
            <a href="/" class="logo">EMPODÉRATE</a>
            <a href="/" class="cta-button">🚀 Usar App Gratis</a>
        </div>
    </header>
    
    <main>
        <h1>📚 Blog Empresarial</h1>
        <p class="subtitle">Guías, consejos y recursos para emprendedores en Panamá</p>
        
        <div class="articles-grid">
$articleCards
        </div>
    </main>
    
    <footer>
        <p>© 2024 Empodérate · <a href="../index.html" style="color: #00E5FF;">Ir a la App</a></p>
    </footer>
</body>
</html>
''';
}

// Genera sitemap.xml
String generateSitemap(String baseUrl) {
  final now = DateTime.now().toIso8601String().split('T')[0];
  final articleUrls = articles.map((a) => '''
    <url>
        <loc>$baseUrl/blog/${a['slug']}.html</loc>
        <lastmod>$now</lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.8</priority>
    </url>''').join('\n');
  
  return '''<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>$baseUrl/</loc>
        <lastmod>$now</lastmod>
        <changefreq>daily</changefreq>
        <priority>1.0</priority>
    </url>
    <url>
        <loc>$baseUrl/blog/</loc>
        <lastmod>$now</lastmod>
        <changefreq>daily</changefreq>
        <priority>0.9</priority>
    </url>
$articleUrls
</urlset>
''';
}

void main() async {
  print('🚀 Generando blog SEO...\n');
  
  // Crear directorio web/blog si no existe
  final blogDir = Directory('web/blog');
  if (!await blogDir.exists()) {
    await blogDir.create(recursive: true);
    print('📁 Creado directorio: web/blog/');
  }
  
  // Generar páginas de artículos
  for (final article in articles) {
    final html = generateArticlePage(article);
    final file = File('web/blog/${article['slug']}.html');
    await file.writeAsString(html);
    print('✅ Generado: ${article['slug']}.html');
  }
  
  // Generar index del blog
  final indexHtml = generateBlogIndex();
  await File('web/blog/index.html').writeAsString(indexHtml);
  print('✅ Generado: index.html');
  
  // Generar sitemap
  final sitemap = generateSitemap('https://tudominio.com'); // TODO: Cambiar por tu dominio real
  await File('web/sitemap.xml').writeAsString(sitemap);
  print('✅ Generado: sitemap.xml');
  
  print('\n🎉 ¡Blog SEO generado exitosamente!');
  print('📂 Archivos en: web/blog/');
  print('⚠️  Recuerda actualizar el baseUrl en sitemap.xml con tu dominio real.');
}
