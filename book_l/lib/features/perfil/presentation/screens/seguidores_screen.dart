import 'package:flutter/material.dart';
import 'perfil_screen.dart';
import '../controller/perfil_controller.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/domain/entities/usuario.dart';

class SeguidoresScreen extends StatefulWidget {
  final int idUsuarioFocus;
  final bool isSeguidores;

  const SeguidoresScreen({
    super.key,
    required this.idUsuarioFocus,
    this.isSeguidores = true,
  });

  @override
  State<SeguidoresScreen> createState() => _SeguidoresScreenState();
}

class _SeguidoresScreenState extends State<SeguidoresScreen> {
  List<Usuario> usuariosList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.isSeguidores) {
      // Seguidores del usuario focus (id_seguido = focus, buscando id_seguidor)
      usuariosList = PerfilController().getSeguidores(widget.idUsuarioFocus);
    } else {
      // Usuarios a los que sigue el focus (id_seguidor = focus, buscando id_seguido)
      usuariosList = PerfilController().getSeguidos(widget.idUsuarioFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB), // General BackGround
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Custom Header alineado idéntico al de PerfilScreen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF88D288),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  Text(
                    widget.isSeguidores ? 'Seguidores' : 'Seguidos',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer to balance back button
                ],
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: usuariosList.isEmpty
                  ? Center(
                      child: Text(
                        widget.isSeguidores 
                            ? 'No tiene seguidores aún.' 
                            : 'No sigue a nadie.',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: usuariosList.length,
                      itemBuilder: (context, index) {
                        return _buildSeguidorItem(
                          context: context,
                          usuario: usuariosList[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeguidorItem({
    required BuildContext context,
    required Usuario usuario,
  }) {
    final usernameStr = '@${usuario.nombreCompleto.replaceAll(" ", "").toLowerCase()}';
    final avatar = usuario.avatarUrl ?? 'https://ui-avatars.com/api/?name=${usuario.nombreCompleto}&background=random';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilScreen(idUsuario: usuario.idUsuario),
          ),
        ).then((_) {
            // Actualizar vista al regresar por si cambió el estado siguiendo
            setState(() {
              _loadData();
            });
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              padding: const EdgeInsets.all(2), // Border
              decoration: const BoxDecoration(
                color: Color(0xFF4DC130), // Green border of image
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(avatar),
              ),
            ),
            const SizedBox(width: 15),

            // Nombres
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombreCompleto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    usernameStr,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Action Button reactivo
            ListenableBuilder(
              listenable: PerfilController(),
              builder: (context, _) {
                final myId = AppSession().usuarioId ?? 0;
                if (myId == usuario.idUsuario) {
                  return const SizedBox.shrink(); // Es el usuario mismo
                }
                final isFollowing = PerfilController().isFollowing(myId, usuario.idUsuario);
                
                return ElevatedButton(
                  onPressed: () {
                    PerfilController().toggleSeguir(myId, usuario.idUsuario);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing
                        ? const Color(0xFFE3EFFC)
                        : const Color(0xFF4DC130),
                    foregroundColor: isFollowing ? Colors.black87 : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(
                    isFollowing ? 'Siguiendo' : 'Seguir',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
