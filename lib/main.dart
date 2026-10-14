
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String apiBaseUrl = 'https://receitasapi-b-2025.vercel.app';

final NumberFormat formatoMoeda =
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LivroReceitasApp());
}

// MODELO

class Receita {
  final int id;
  final String nome;
  final String tipo;
  final String ingredientes;
  final String modoFazer;
  final String img;
  final double custoAproximado;

  const Receita({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.ingredientes,
    required this.modoFazer,
    required this.img,
    required this.custoAproximado,
  });

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id: int.tryParse('${json['id']}') ?? 0,
      nome: '${json['nome'] ?? 'Receita sem nome'}',
      tipo: '${json['tipo'] ?? 'DOCE'}',
      ingredientes: '${json['ingredientes'] ?? ''}',
      modoFazer: '${json['modoFazer'] ?? ''}',
      img: '${json['img'] ?? ''}',
      custoAproximado: double.tryParse(
            '${json['custoAproximado'] ?? 0}'.replaceAll(',', '.'),
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'tipo': tipo,
      'ingredientes': ingredientes,
      'modoFazer': modoFazer,
      'img': img,
      'custoAproximado': custoAproximado,
    };
  }
}

// API

class ReceitaApi {
  static Future<List<Receita>> listar() async {
    final resposta = await http
        .get(Uri.parse('$apiBaseUrl/receitas'))
        .timeout(const Duration(seconds: 20));

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception('Erro ao carregar receitas: ${resposta.statusCode}');
    }

    final dados = jsonDecode(utf8.decode(resposta.bodyBytes));

    final List lista;

    if (dados is List) {
      lista = dados;
    } else if (dados is Map && dados['receitas'] is List) {
      lista = dados['receitas'];
    } else {
      lista = [];
    }

    return lista
        .whereType<Map>()
        .map((item) => Receita.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> criar(Receita receita) async {
    final resposta = await http
        .post(
          Uri.parse('$apiBaseUrl/receitas'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(receita.toJson()),
        )
        .timeout(const Duration(seconds: 20));

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception('Erro ao cadastrar: ${resposta.statusCode}');
    }
  }

  static Future<void> atualizar(int id, Receita receita) async {
    final resposta = await http
        .put(
          Uri.parse('$apiBaseUrl/receitas/$id'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(receita.toJson()),
        )
        .timeout(const Duration(seconds: 20));

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception('Erro ao atualizar: ${resposta.statusCode}');
    }
  }

  static Future<void> excluir(int id) async {
    final resposta = await http
        .delete(Uri.parse('$apiBaseUrl/receitas/$id'))
        .timeout(const Duration(seconds: 20));

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception('Erro ao excluir: ${resposta.statusCode}');
    }
  }
}

// APLICATIVO

class LivroReceitasApp extends StatelessWidget {
  const LivroReceitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    const vinho = Color(0xFF813E50);
    const fundo = Color(0xFFFAF7F4);
    const rosa = Color(0xFFFBD9DF);

    return MaterialApp(
      title: 'Sabor & Afeto',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: vinho,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: fundo,
        appBarTheme: const AppBarTheme(
          backgroundColor: fundo,
          foregroundColor: Color(0xFF30282A),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE6DAD8)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFCE9EC),
          selectedItemColor: vinho,
          unselectedItemColor: Color(0xFF65585B),
          type: BottomNavigationBarType.fixed,
          elevation: 5,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: rosa,
          foregroundColor: vinho,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: vinho,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// SPLASH COM ANIMAÇÃO

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PrincipalScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: cor.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    size: 68,
                    color: cor.primary,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Sabor & Afeto',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Receitas para compartilhar'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// HOME E NAVEGAÇÃO INFERIOR

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  // 0 = Splash, 1 = Home, 2 = Nova receita.
  // A Splash abre como uma tela separada.
  int _indice = 1;

  List<Receita> _receitas = [];
  bool _carregando = true;
  String? _erro;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    carregarReceitas();
    restaurarAba();
  }

  Future<void> restaurarAba() async {
    final prefs = await SharedPreferences.getInstance();
    final indice = prefs.getInt('ultima_aba') ?? 1;

    if (!mounted) return;

    setState(() {
      _indice = indice == 2 ? 2 : 1;
    });
  }

  Future<void> salvarAba(int indice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ultima_aba', indice);
  }

  Future<void> carregarReceitas() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final dados = await ReceitaApi.listar();

      if (!mounted) return;

      setState(() {
        _receitas = dados;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void selecionarAba(int indice) {
    if (indice == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        ),
      );
      return;
    }

    setState(() {
      _indice = indice;
    });

    salvarAba(indice);
  }

  Future<void> abrirFormulario({Receita? receita}) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormularioReceitaScreen(
          receita: receita,
        ),
      ),
    );

    if (resultado == true) {
      carregarReceitas();
    }
  }

  Future<void> abrirDetalhes(Receita receita) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DetalhesReceitaScreen(
          receita: receita,
        ),
      ),
    );

    if (resultado == true) {
      carregarReceitas();
    }
  }

  Future<void> confirmarExclusao(Receita receita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir receita?'),
        content: Text(
          'Deseja excluir "${receita.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ReceitaApi.excluir(receita.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receita excluída com sucesso!'),
        ),
      );

      carregarReceitas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _receitas.where((receita) {
      final busca = _busca.toLowerCase();

      return receita.nome.toLowerCase().contains(busca) ||
          receita.ingredientes.toLowerCase().contains(busca);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _indice == 1 ? 'Sabor & Afeto' : 'Nova receita',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 23,
              ),
            ),
            if (_indice == 1)
              const Text(
                'Seu caderno de sabores',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          if (_indice == 1)
            IconButton(
              tooltip: 'Atualizar receitas',
              onPressed: carregarReceitas,
              icon: const Icon(Icons.refresh_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),

      // Não existe mais botão flutuante de cadastro.
      body: _indice == 1
          ? telaInicio(filtradas)
          : FormularioReceitaScreen(
              key: const ValueKey('nova_receita_embutida'),
              embutido: true,
              aoSalvar: () {
                setState(() {
                  _indice = 1;
                });
                salvarAba(1);
                carregarReceitas();
              },
            ),

      // Barra inferior com Splash, Home e Nova.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        onTap: selecionarAba,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            activeIcon: Icon(Icons.bolt_rounded),
            label: 'Splash',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_rounded),
            activeIcon: Icon(Icons.add_rounded),
            label: 'Nova',
          ),
        ],
      ),
    );
  }

  Widget telaInicio(List<Receita> filtradas) {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erro != null && _receitas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 55,
              ),
              const SizedBox(height: 12),
              const Text(
                'Não foi possível conectar à API.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _erro!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: carregarReceitas,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: carregarReceitas,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : const Color(0xFFFBD9DF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Feito em casa,'),
                      Text(
                        'feito com carinho.',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? null
                              : const Color(0xFF813E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_receitas.length} receitas no seu livro',
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.soup_kitchen_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (valor) {
              setState(() {
                _busca = valor;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Buscar receita ou ingrediente',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Todas as receitas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (filtradas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  _receitas.isEmpty
                      ? 'Ainda não há receitas cadastradas.'
                      : 'Nenhuma receita encontrada.',
                ),
              ),
            )
          else
            ...filtradas.map(
              (receita) => ReceitaCard(
                receita: receita,
                aoTocar: () => abrirDetalhes(receita),
                aoEditar: () => abrirFormulario(receita: receita),
                aoExcluir: () => confirmarExclusao(receita),
              ),
            ),
        ],
      ),
    );
  }
}

// CARD DA RECEITA

class ReceitaCard extends StatelessWidget {
  final Receita receita;
  final VoidCallback aoTocar;
  final VoidCallback aoEditar;
  final VoidCallback aoExcluir;

  const ReceitaCard({
    super.key,
    required this.receita,
    required this.aoTocar,
    required this.aoEditar,
    required this.aoExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 110,
              child: imagemReceita(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receita.tipo.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      receita.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatoMoeda.format(receita.custoAproximado),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Opções da receita',
              onSelected: (valor) {
                if (valor == 'editar') aoEditar();
                if (valor == 'excluir') aoExcluir();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'excluir',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 10),
                      Text('Excluir'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget imagemReceita() {
    if (receita.img.trim().isEmpty) {
      return Container(
        color: const Color(0xFFF0E1E3),
        child: const Icon(Icons.restaurant_rounded, size: 38),
      );
    }

    return Image.network(
      receita.img,
      fit: BoxFit.cover,
      errorBuilder: (context, erro, pilha) {
        return Container(
          color: const Color(0xFFF0E1E3),
          child: const Icon(Icons.image_not_supported_outlined, size: 35),
        );
      },
    );
  }
}

// FORMULÁRIO DE CADASTRO E EDIÇÃO

class FormularioReceitaScreen extends StatefulWidget {
  final Receita? receita;
  final bool embutido;
  final VoidCallback? aoSalvar;

  const FormularioReceitaScreen({
    super.key,
    this.receita,
    this.embutido = false,
    this.aoSalvar,
  });

  @override
  State<FormularioReceitaScreen> createState() =>
      _FormularioReceitaScreenState();
}

class _FormularioReceitaScreenState
    extends State<FormularioReceitaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nome = TextEditingController();
  final _ingredientes = TextEditingController();
  final _modo = TextEditingController();
  final _img = TextEditingController();
  final _custo = TextEditingController();

  String _tipo = 'DOCE';
  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    final receita = widget.receita;

    if (receita != null) {
      _nome.text = receita.nome;
      _ingredientes.text = receita.ingredientes;
      _modo.text = receita.modoFazer;
      _img.text = receita.img;
      _custo.text = receita.custoAproximado.toStringAsFixed(2)
          .replaceAll('.', ',');

      _tipo = ['DOCE', 'SALGADA', 'BEBIDA'].contains(receita.tipo)
          ? receita.tipo
          : 'DOCE';
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _ingredientes.dispose();
    _modo.dispose();
    _img.dispose();
    _custo.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final textoCusto = _custo.text.trim();

    final custo = double.tryParse(
      textoCusto.contains(',')
          ? textoCusto.replaceAll('.', '').replaceAll(',', '.')
          : textoCusto,
    );

    if (custo == null || custo < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um custo válido.'),
        ),
      );
      return;
    }

    final receita = Receita(
      id: widget.receita?.id ?? 0,
      nome: _nome.text.trim(),
      tipo: _tipo,
      ingredientes: _ingredientes.text.trim(),
      modoFazer: _modo.text.trim(),
      img: _img.text.trim(),
      custoAproximado: custo,
    );

    setState(() {
      _salvando = true;
    });

    try {
      if (widget.receita == null) {
        await ReceitaApi.criar(receita);
      } else {
        await ReceitaApi.atualizar(
          widget.receita!.id,
          receita,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.receita == null
                ? 'Receita cadastrada com sucesso!'
                : 'Receita atualizada com sucesso!',
          ),
        ),
      );

      if (widget.embutido) {
        _formKey.currentState?.reset();
        _nome.clear();
        _ingredientes.clear();
        _modo.clear();
        _img.clear();
        _custo.clear();

        setState(() {
          _tipo = 'DOCE';
        });

        widget.aoSalvar?.call();
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.embutido
          ? null
          : AppBar(
              title: Text(
                widget.receita == null
                    ? 'Nova receita'
                    : 'Editar receita',
              ),
            ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          children: [
            if (widget.embutido) ...[
              Text(
                'Compartilhe um sabor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 5),
              const Text('Preencha os detalhes da sua receita.'),
              const SizedBox(height: 20),
            ],
            campoTitulo('Nome da receita'),
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ex.: Bolo de cenoura',
              ),
              validator: (valor) =>
                  valor == null || valor.trim().isEmpty
                      ? 'Informe o nome da receita.'
                      : null,
            ),
            const SizedBox(height: 16),
            campoTitulo('Tipo de receita'),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(
                  value: 'DOCE',
                  child: Text('Doce'),
                ),
                DropdownMenuItem(
                  value: 'SALGADA',
                  child: Text('Salgada'),
                ),
                DropdownMenuItem(
                  value: 'BEBIDA',
                  child: Text('Bebida'),
                ),
              ],
              onChanged: (valor) {
                setState(() {
                  _tipo = valor ?? 'DOCE';
                });
              },
            ),
            const SizedBox(height: 16),
            campoTitulo('Ingredientes'),
            TextFormField(
              controller: _ingredientes,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Liste os ingredientes e quantidades',
              ),
              validator: (valor) =>
                  valor == null || valor.trim().isEmpty
                      ? 'Informe os ingredientes.'
                      : null,
            ),
            const SizedBox(height: 16),
            campoTitulo('Modo de preparo'),
            TextFormField(
              controller: _modo,
              minLines: 4,
              maxLines: 7,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Explique o passo a passo',
              ),
              validator: (valor) =>
                  valor == null || valor.trim().isEmpty
                      ? 'Informe o modo de preparo.'
                      : null,
            ),
            const SizedBox(height: 16),
            campoTitulo('URL da imagem (opcional)'),
            TextFormField(
              controller: _img,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'https://...',
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return null;
                }

                final uri = Uri.tryParse(valor.trim());

                if (uri == null ||
                    !uri.hasScheme ||
                    (uri.scheme != 'https' && uri.scheme != 'http')) {
                  return 'Informe uma URL válida.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            campoTitulo('Custo aproximado (R\$)'),
            TextFormField(
              controller: _custo,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Ex.: 12,50',
                prefixText: 'R\$ ',
              ),
              validator: (valor) =>
                  valor == null || valor.trim().isEmpty
                      ? 'Informe o custo aproximado.'
                      : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _salvando ? null : salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _salvando ? 'Salvando...' : 'Salvar receita',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget campoTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// DETALHES DA RECEITA

class DetalhesReceitaScreen extends StatelessWidget {
  final Receita receita;

  const DetalhesReceitaScreen({
    super.key,
    required this.receita,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da receita'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1.45,
              child: receita.img.trim().isEmpty
                  ? Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 70,
                      ),
                    )
                  : Image.network(
                      receita.img,
                      fit: BoxFit.cover,
                      errorBuilder: (context, erro, pilha) {
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 60,
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            receita.tipo.toUpperCase(),
            style: TextStyle(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            receita.nome,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Custo: ${formatoMoeda.format(receita.custoAproximado)}',
              ),
            ],
          ),
          const SizedBox(height: 22),
          secao(
            context,
            'Ingredientes',
            receita.ingredientes,
            Icons.shopping_basket_outlined,
          ),
          const SizedBox(height: 14),
          secao(
            context,
            'Modo de preparo',
            receita.modoFazer,
            Icons.menu_book_outlined,
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () async {
              final alterou = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => FormularioReceitaScreen(
                    receita: receita,
                  ),
                ),
              );

              if (alterou == true && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar receita'),
          ),
        ],
      ),
    );
  }

  Widget secao(
    BuildContext context,
    String titulo,
    String conteudo,
    IconData icone,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 9),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              conteudo.isEmpty ? 'Não informado.' : conteudo,
              style: const TextStyle(
                height: 1.5,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
