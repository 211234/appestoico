import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final List<Map<String, dynamic>> resources = [
    {
      'section': 'Libros y Documentos',
      'items': [
        {
          'title': 'Manual Semana Estoica (PDF)',
          'subtitle': 'Guía Stoic Week en español',
          'url': 'https://es.scribd.com/document/681571333/Stoic-Week-Students-Spanish?utm_source=chatgpt.com',
        },
        {
          'title': 'Meditaciones',
          'subtitle': 'Traducción de Marco Aurelio en español',
          'url': 'https://web.seducoahuila.gob.mx/biblioweb/upload/Marco%20Aurelio-Meditaciones.pdf',
        },
        {
          'title': 'Enchiridion (Manual de Epicteto)',
          'subtitle': 'Colección de máximas estoicas',
          'url': 'https://www.nueva-acropolis.es/libros/Epicteto-Maximas.pdf',
        },
        {
          'title': 'Cartas a Lucilio (Séneca)',
          'subtitle': 'Colección de cartas estoicas',
          'url': 'https://www.sura.com/arteycultura/wp-content/uploads/2023/03/sura-habitar-virtud-libro-seneca-digital.pdf',
        },
        {
          'title': 'De la firmeza del sabio (Séneca)',
          'subtitle': 'Contexto histórico y análisis',
          'url': 'https://en.wikipedia.org/wiki/Seneca_the_Younger',
        },
        {
          'title': 'De finibus bonorum et malorum',
          'subtitle': 'Contexto del estoicismo',
          'url': 'https://en.wikipedia.org/wiki/Stoicism',
        },
      ],
    },
    {
      'section': 'Videos y Playlists',
      'items': [
        {
          'title': '8 Hábitos Estoicos para Vivir Más Feliz y Sufrir Menos',
          'subtitle': 'Por Pepe García',
          'url': 'https://youtu.be/hwMdJPikI0g?si=jLDNVuUXDmVXO9m3',
        },
        {
          'title': 'Estoicismo: una filosofía de vida',
          'subtitle': 'Por Massimo',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+massimo',
        },
        {
          'title': 'ESTOICISMO / Todo lo que DEBES saber',
          'subtitle': 'Playlist completa',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+todo+lo+que+debes+saber',
        },
        {
          'title': 'ESTOICISMO - Epicteto, Séneca y Marco Aurelio',
          'subtitle': 'Resumen reciente',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+epicteto+seneca+marco+aurelio',
        },
        {
          'title': 'Los mejores libros de Estoicismo | Cómo empezar',
          'subtitle': 'Guía de recursos',
          'url':
              'https://www.youtube.com/results?search_query=mejores+libros+estoicismo',
        },
        {
          'title': 'SENECA – FILOSOFÍA ESTOICA',
          'subtitle': 'Serie completa',
          'url':
              'https://www.youtube.com/results?search_query=seneca+filosofia+estoica',
        },
        {
          'title': 'Pepe García "El Estoico"',
          'subtitle': 'Canal YouTube - contenido continuo',
          'url': 'https://www.youtube.com/@elestoicoesp',
        },
        {
          'title': 'Podcast El Estoico',
          'subtitle': 'Playlist en YouTube',
          'url':
              'https://www.youtube.com/results?search_query=podcast+el+estoico',
        },
        {
          'title': 'Pórtico Estoico',
          'subtitle': 'Ensayos y reflexiones diarias',
          'url': 'https://www.youtube.com/results?search_query=portico+estoico',
        },
      ],
    },
    {
      'section': 'Podcasts y Audio',
      'items': [
        {
          'title': 'Podcast El Estoico',
          'subtitle': 'En Apple Podcasts',
          'url':
              'https://podcasts.apple.com/es/podcast/el-estoico-estoicismo-en-espa%C3%B1ol/id1513791229',
        },
        {
          'title': 'Episodio: Terapia Cognitiva y Estoicismo',
          'subtitle': 'El Estoico #195',
          'url': 'https://podcasts.apple.com/uy/podcast/195-terapia-cognitiva-para-pensamientos-rumiantes-psic%C3%B3logo/id1513791229?i=1000739667363',
        },
        {
          'title': 'Podcast Estoicismo en Acción',
          'subtitle': 'Pórtico Estoico (Spotify / YouTube)',
          'url': 'https://open.spotify.com/search/estoicismo',
        },
        {
          'title': 'Las 8 preguntas más poderosas del estoicismo',
          'subtitle': 'El Estoico',
          'url': 'https://podcast-de-el-estoico-estoicismo-en-espanol.simplecast.com/episodes/191-las-8-preguntas-mas-poderosas-del-estoicismo',
        },
        {
          'title': 'Momentos: ejercicios para tener paciencia',
          'subtitle': 'El Estoico',
          'url':
              'https://www.youtube.com/results?search_query=podcast+el+estoico+paciencia',
        },
        {
          'title': 'Podcast Estoicismo aplicado a emociones',
          'subtitle': 'Disponible en Spotify / iVoox',
          'url': 'https://open.spotify.com/search/estoicismo',
        },
      ],
    },
    {
      'section': 'Videos Cortos / Clips Estoicos',
      'items': [
        {
          'title': 'Lecciones sobre Epicteto, Marco Aurelio y Séneca',
          'subtitle': 'Videos educativos en YouTube',
          'url':
              'https://www.youtube.com/results?search_query=epicteto+marco+aurelio+seneca',
        },
        {
          'title': 'Lecciones sobre hábitos estoicos concretos',
          'subtitle': 'Estoicismo Consciente',
          'url': 'https://youtu.be/x03aNQhyCis?si=KbQOWvQ9NjjpNjSI',
        },
        {
          'title': 'Frases estoicas animadas',
          'subtitle': 'Clips inspiradores',
          'url':
              'https://www.youtube.com/results?search_query=frases+estoicas+animadas',
        },
        {
          'title': 'Meditaciones guiadas inspiradas en Marco Aurelio',
          'subtitle': 'Videos relajantes',
          'url':
              'https://www.youtube.com/results?search_query=meditaciones+marco+aurelio',
        },
        {
          'title': 'Amor fati y aceptación',
          'subtitle': 'Enseñanzas estoicas',
          'url':
              'https://www.youtube.com/results?search_query=amor+fati+estoicismo',
        },
        {
          'title': 'Estoicismo práctico para productividad',
          'subtitle': 'Clips aplicables',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+productividad',
        },
      ],
    },
    {
      'section': 'Guías, Resúmenes y Material de Lectura',
      'items': [
        {
          'title': 'Resumen de Meditaciones de Marco Aurelio',
          'subtitle': 'Blogs en español',
          'url': 'https://www.wikipedia.org/wiki/Meditaciones',
        },
        {
          'title': 'Resumen de Manual de Epicteto',
          'subtitle': 'Blogs filosóficos',
          'url': 'https://www.wikipedia.org/wiki/Epicteto',
        },
        {
          'title': 'Prácticas estoicas diarias',
          'subtitle': 'Guías y blogs',
          'url': 'https://www.google.com/search?q=blog+estoicismo+practica',
        },
        {
          'title': 'Guía de Semana Estoica traducida',
          'subtitle': 'Repositorios online',
          'url': 'https://www.scribd.com/',
        },
        {
          'title': 'Recursos estoicos de The Stoic Fellowship',
          'subtitle': 'Listados varios',
          'url': 'https://stoicfellowship.com/es/recursos-estoicos',
        },
        {
          'title': 'PDFs de citas estoicas para imprimir',
          'subtitle': 'Colecciones en español',
          'url': 'https://www.google.com/search?q=citas+estoicas+español+pdf',
        },
        {
          'title': 'Resúmenes comparativos de Séneca y Epicteto',
          'subtitle': 'Artículos en línea',
          'url': 'https://www.studocu.com/es-mx/document/instituto-tecnologico-del-valle-de-etla/funciones-y-relaciones/los-estoicos-apuntes/56871336',
        },
      ],
    },
    {
      'section': 'Entrevistas y Conversaciones',
      'items': [
        {
          'title': 'Entrevistas con filósofos contemporáneos',
          'subtitle': 'Sobre estoicismo en YouTube',
          'url':
              'https://www.youtube.com/results?search_query=entrevista+filosofo+estoicismo',
        },
        {
          'title': 'Conversaciones con Pepe García y expertos',
          'subtitle': 'Podcasts y YouTube',
          'url': 'https://www.youtube.com/results?search_query=Conversaciones+con+Pepe+Garc%C3%ADa+y+expertos',
        },
        {
          'title': 'Entrevistas sobre estoicismo en podcasts',
          'subtitle': 'Contenido cultural',
          'url': 'https://podcasts.apple.com/search?term=estoicismo',
        },
        {
          'title': 'Charlas sobre aplicación práctica',
          'subtitle': 'Podcasts y YouTube',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+vida+diaria',
        },
        {
          'title': 'Mesa redonda sobre estoicismo y psicología',
          'subtitle': 'Disponible en YouTube',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+psicologia',
        },
        {
          'title': 'Entrevista con autores modernos',
          'subtitle': 'Podcast / YouTube',
          'url':
              'https://www.youtube.com/results?search_query=autores+estoicismo+moderno',
        },
      ],
    },
    {
      'section': 'Aplicaciones Estoicas a la Vida Actual',
      'items': [
        {
          'title': 'Estoicismo y manejo de emociones',
          'subtitle': 'Videos prácticos',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+emociones',
        },
        {
          'title': 'Estoicismo y relaciones interpersonales',
          'subtitle': 'Guía aplicada',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+relaciones',
        },
        {
          'title': 'Estoicismo para productividad y trabajo',
          'subtitle': 'Consejos prácticos',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+productividad+trabajo',
        },
        {
          'title': 'Estoicismo y felicidad moderna',
          'subtitle': 'Enfoque contemporáneo',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+felicidad',
        },
        {
          'title': 'Estoicismo y autocontrol',
          'subtitle': 'Videos cortos',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+autocontrol',
        },
        {
          'title': 'Estoicismo y ansiedad',
          'subtitle': 'Videos prácticos',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+ansiedad',
        },
        {
          'title': 'Cómo aplicar amor fati en la vida contemporánea',
          'subtitle': 'Guías modernas',
          'url': 'https://www.youtube.com/results?search_query=amor+fati+vida',
        },
        {
          'title': 'Estoicismo y minimalismo mental',
          'subtitle': 'Simplificación práctica',
          'url':
              'https://www.youtube.com/results?search_query=estoicismo+minimalismo',
        },
        {
          'title': 'Aplicar disciplina estoica diaria',
          'subtitle': 'Rutinas y hábitos',
          'url':
              'https://www.youtube.com/results?search_query=disciplina+estoica+diaria',
        },
        {
          'title': 'Ejercicios estoicos diarios',
          'subtitle': 'Prácticas en video',
          'url':
              'https://www.youtube.com/results?search_query=ejercicios+estoicos',
        },
      ],
    },
  ];

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Guía Estoica',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu ruta completa hacia la maestría estoica',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),
                ...resources.map((section) {
                  return _buildSectionCard(section);
                }).toList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de sección
          Text(
            section['section'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Items de la sección
          ...List<Widget>.from(
            (section['items'] as List).map(
              (item) => _buildResourceItem(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _launchUrl(item['url']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.open_in_new,
              color: Colors.purple.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
