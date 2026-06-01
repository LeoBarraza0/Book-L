import 'package:flutter/material.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/chatbot/infrastructure/adapters/out/repositories/chatbot_repository_impl.dart';
import 'package:book_l/features/chatbot/application/usecases/get_respuesta_chatbot_usecase.dart';
import '../controller/chatbot_controller.dart';
import '../controller/chatbot_state.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chatbot_action_card.dart';
import '../widgets/typing_indicator.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Instanciación siguiendo Clean Architecture:
  // Screen → Controller → UseCase → Repository (impl)
  late final ChatbotController _chatbotController;

  @override
  void initState() {
    super.initState();

    // Inyección de dependencias manual (sin DI container por ahora)
    final repository = ChatbotRepositoryImpl();
    final useCase = GetRespuestaChatbotUseCase(repository);
    _chatbotController = ChatbotController(getRespuesta: useCase);

    // Escuchar cambios del controller para redibujar
    _chatbotController.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _chatbotController.removeListener(_onStateChanged);
    _chatbotController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messageController.clear();
      _chatbotController.enviarMensaje(text);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Determina si hay mensajes activos en la conversación
  bool get _hasMessages {
    final state = _chatbotController.state;
    if (state is ChatbotConversando) return state.mensajes.isNotEmpty;
    if (state is ChatbotPensando) return state.mensajes.isNotEmpty;
    if (state is ChatbotError) return state.mensajesPrevios.isNotEmpty;
    return false;
  }

  /// Obtiene la lista de mensajes del estado actual
  List<ChatMessage> get _currentMessages {
    final state = _chatbotController.state;
    if (state is ChatbotConversando) return state.mensajes;
    if (state is ChatbotPensando) return state.mensajes;
    if (state is ChatbotError) return state.mensajesPrevios;
    return [];
  }

  /// Indica si el bot está "pensando" actualmente
  bool get _isThinking => _chatbotController.state is ChatbotPensando;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          Column(
            children: [
              // Header blanco superior, pegado al borde y con esquinas redondeadas abajo
              _buildHeader(context),

              // Contenido scrolleable: vista inicial o chat activo
              Expanded(
                child: _hasMessages ? _buildChatView() : _buildInitialView(),
              ),
            ],
          ),

          // Contenedor grande del input de chat
          Positioned(
            bottom: 110, // Arriba del navbar
            left: 20,
            right: 20,
            child: _buildChatInput(),
          ),

          // Bottom Navigation Bar
          const Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SharedBottomNavBar(selectedIndex: 3),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Vista Inicial (sin mensajes) — imagen central + cards informativas
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildInitialView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          // Ilustración de Buki central
          Image.asset(
            'assets/images/Chatbot_Icon.png',
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.smart_toy,
                size: 100,
                color: Color(0xFF4DC130),
              );
            },
          ),
          const SizedBox(height: 20),

          // Saludo centrado dinámico (obtenido de la sesión actual)
          Text(
            'Hola, ${AppSession().nombreCompleto?.split(' ').first ?? 'Usuario'}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF96D786),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            '¿How can assist you today?',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF212121),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Opciones de acción sugeridas (al tocarlas envían el mensaje)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ChatbotActionCard(
                    onTap: () =>
                        _chatbotController.enviarMensaje('Cómo usar la app'),
                    title: 'Cómo usar la app',
                    subtitle: 'Instructivo de uso y algunas cosas útiles',
                    icon: Icons.offline_bolt_outlined,
                    backgroundColor: const Color(0xFFC4E69D),
                    contentColor: const Color(0xFF5A5A5A),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ChatbotActionCard(
                    onTap: () => _chatbotController
                        .enviarMensaje('Cómo crear una lección'),
                    title: 'Cómo crear una\nlección',
                    icon: Icons.draw_outlined,
                    backgroundColor: const Color(0xFFF6AAB1),
                    contentColor: const Color(0xFF5A5A5A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 160),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Vista de Chat — lista de mensajes con burbujas
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildChatView() {
    final messages = _currentMessages;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 260),
      itemCount: messages.length +
          (_isThinking ? 1 : 0), // +1 para el indicador de "pensando"
      itemBuilder: (context, index) {
        // Si es el último item y el bot está pensando, mostrar indicador
        if (_isThinking && index == messages.length) {
          return const TypingIndicator();
        }
        return ChatMessageBubble(message: messages[index]);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header Blanco Superior
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          // Botón Atrás
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF96D786),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  final role = BooklService().currentRole;
                  Navigator.pushReplacementNamed(
                    context,
                    role == 'admin' ? '/admin_Home' : '/home',
                  );
                }
              },
            ),
          ),

          // Título Centrado
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Booki',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.verified,
                      color: Color(0xFF4DC130),
                      size: 20,
                    ),
                  ],
                ),
                const Text(
                  'Chatbot asistente',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),

          // Espaciador del mismo ancho que el botón Atrás
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Input de Mensaje de Chat (Grande)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildChatInput() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: _messageController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendMessage(),
            decoration: const InputDecoration(
              hintText: 'What would you like to know?',
              hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF4DC130),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
