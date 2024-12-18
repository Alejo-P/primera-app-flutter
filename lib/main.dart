import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          // Esquema de colores personalizado para la aplicación.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // ↓ Add this.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>{}; // Variable para almacenar las palabras favoritas.

  void toggleFavorite() {
    if (favorites.contains(current)) {
      // Si la palabra actual ya está en la lista de favoritos, quitarla.
      favorites.remove(current);
    } else {
      // Si no, añadirla.
      favorites.add(current);
    }

    // Notificar a los widgets que escuchan los cambios.
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Índice de la pestaña seleccionada.

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        // Página de generador de palabras.
        page = GeneratorPage();
        break;
      case 1:
        // Página de favoritos.
        page = FavoritesPage();
        break;
      default:
        // Si no se selecciona ninguna pestaña, lanzar un error.
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth > 600, // Extender la barra de navegación si el ancho es mayor a 600.
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  selectedIndex: selectedIndex, // Índice de la pestaña seleccionada.
                  onDestinationSelected: (value) {
                    print('selected: $value');
                    setState(() {
                      // Actualizar el índice de la pestaña seleccionada.
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page, // Mostrar la página seleccionada.
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Obtener el estado de la aplicación.
    var pair = appState.current; // Obtener la palabra actual.

    IconData icon; // Icono para el botón de favoritos.
    if (appState.favorites.contains(pair)) {
      // Si la palabra actual está en la lista de favoritos, mostrar el icono de favoritos.
      icon = Icons.favorite;
    } else {
      // Si no, mostrar el icono de favoritos vacío.
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column( // Columna para alinear los widgets verticalmente.
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Llamar al método toggleFavorite() del estado de la aplicación.
                  appState.toggleFavorite();
                },
                icon: Icon(icon), // Usar el icono seleccionado.
                label: Text('Favorite'), // Etiqueta del botón.
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Llamar al método getNext() del estado de la aplicación.
                  appState.getNext();
                },
                child: Text('Next'), // Etiqueta del botón.
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Clase BigCard que muestra la palabra actual.
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context); // Para acceder al tema actual de la aplicación.
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    ); // Estilo de texto personalizado.

    return Card(
      // Unir el widget Card con el widget Padding.
      color: theme.colorScheme.primary, // Usar el color primario del tema.
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asPascalCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}", // Añadir etiqueta semántica (Para accesibilidad).
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Obtener el estado de la aplicación.
    var favorites = appState.favorites; // Obtener la lista de favoritos.

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        var pair = favorites.elementAt(index); // Obtener la palabra actual.

        return ListTile(
          title: Text(pair.asPascalCase), // Mostrar la palabra actual.
          onTap: () {
            // Llamar al método toggleFavorite() del estado de la aplicación.
            appState.toggleFavorite();
          },
        );
      },
    );
  }
}
