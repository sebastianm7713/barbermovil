import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';

/// Pantalla de configuración de la aplicación
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkModeEnabled = false;
  String _language = 'Español';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Sección de Cuenta
          _buildSectionHeader('Cuenta'),
          _buildAccountTile(
            icon: Icons.person,
            title: 'Nombre',
            subtitle: user?.name ?? 'Usuario',
            onTap: () {
              _showEditNameDialog(context, user?.name ?? '');
            },
          ),
          _buildAccountTile(
            icon: Icons.email,
            title: 'Correo electrónico',
            subtitle: user?.email ?? '',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se puede cambiar el email desde aquí'),
                ),
              );
            },
          ),
          _buildAccountTile(
            icon: Icons.lock,
            title: 'Cambiar contraseña',
            subtitle: '••••••••',
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),

          const Divider(height: 32),

          // Sección de Notificaciones
          _buildSectionHeader('Notificaciones'),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications,
                color: AppTheme.primary,
              ),
            ),
            title: const Text(
              'Notificaciones',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Activar/desactivar todas las notificaciones'),
            value: _notificationsEnabled,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                if (!value) {
                  _emailNotifications = false;
                  _pushNotifications = false;
                }
              });
            },
          ),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.email,
                color: AppTheme.primary,
              ),
            ),
            title: const Text(
              'Notificaciones por email',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Recibir notificaciones en tu correo'),
            value: _emailNotifications && _notificationsEnabled,
            activeColor: AppTheme.primary,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _emailNotifications = value);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.phone_android,
                color: AppTheme.primary,
              ),
            ),
            title: const Text(
              'Notificaciones push',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Recibir notificaciones en el dispositivo'),
            value: _pushNotifications && _notificationsEnabled,
            activeColor: AppTheme.primary,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _pushNotifications = value);
                  }
                : null,
          ),

          const Divider(height: 32),

          // Sección de Apariencia
          _buildSectionHeader('Apariencia'),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.dark_mode,
                color: AppTheme.primary,
              ),
            ),
            title: const Text(
              'Modo oscuro',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Próximamente disponible'),
            value: _darkModeEnabled,
            activeColor: AppTheme.primary,
            onChanged: null, // Deshabilitado por ahora
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.language,
                color: AppTheme.primary,
              ),
            ),
            title: const Text(
              'Idioma',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(_language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),

          const Divider(height: 32),

          // Sección de Privacidad
          _buildSectionHeader('Privacidad y Seguridad'),
          _buildAccountTile(
            icon: Icons.privacy_tip,
            title: 'Política de privacidad',
            subtitle: 'Ver términos y condiciones',
            onTap: () {
              _showPrivacyPolicy(context);
            },
          ),
          _buildAccountTile(
            icon: Icons.security,
            title: 'Seguridad',
            subtitle: 'Configuración de seguridad',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración de seguridad próximamente'),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Botón de guardar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                _saveSettings(context);
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Guardar el nuevo nombre
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Nombre actualizado: ${controller.text}')),
              );
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text == confirmPasswordController.text) {
                // TODO: Cambiar contraseña
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contraseña actualizada')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Las contraseñas no coinciden')),
                );
              }
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'Español',
              groupValue: _language,
              activeColor: AppTheme.primary,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              activeColor: AppTheme.primary,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'Esta es una aplicación de demostración.\n\n'
            'En una aplicación real, aquí se mostraría la política de privacidad completa, '
            'incluyendo información sobre cómo se recopilan, usan y protegen los datos del usuario.\n\n'
            'Puntos importantes:\n'
            '• Recopilación de datos\n'
            '• Uso de la información\n'
            '• Protección de datos\n'
            '• Derechos del usuario\n'
            '• Cookies y tecnologías similares\n'
            '• Contacto',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _saveSettings(BuildContext context) {
    // TODO: Guardar configuraciones en SharedPreferences o backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configuración guardada exitosamente'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
