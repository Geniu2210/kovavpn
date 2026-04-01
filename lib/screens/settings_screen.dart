import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:kova_vpn/services/theme_service.dart';
import 'package:kova_vpn/services/mmkv_manager.dart';
import 'package:kova_vpn/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoConnect = false;
  bool _killSwitch = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _autoConnect = MmkvManager.decodeSettingsBool('auto_connect');
      _killSwitch = MmkvManager.decodeSettingsBool('kill_switch');
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    MmkvManager.encodeSettingsBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF06060e), const Color(0xFF0a0a1a)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection('General', [
              _buildSwitchTile(
                'Auto Connect',
                'Automatically connect on app start',
                CupertinoIcons.play_circle_fill,
                AppTheme.connectedGreen,
                _autoConnect,
                (value) {
                  setState(() => _autoConnect = value);
                  _saveSetting('auto_connect', value);
                },
                isDark,
              ),
              _buildSwitchTile(
                'Kill Switch',
                'Block internet if VPN disconnects',
                CupertinoIcons.shield_fill,
                AppTheme.disconnectedRed,
                _killSwitch,
                (value) {
                  setState(() => _killSwitch = value);
                  _saveSetting('kill_switch', value);
                },
                isDark,
              ),
            ], isDark),
            const SizedBox(height: 20),
            _buildSection('Appearance', [
              Consumer<ThemeService>(
                builder: (context, themeService, child) {
                  final currentMode = themeService.themeMode == ThemeMode.dark 
                      ? 'Dark' 
                      : themeService.themeMode == ThemeMode.light 
                          ? 'Light' 
                          : 'Auto';
                  
                  return _buildNavigationTile(
                    'Theme',
                    currentMode,
                    CupertinoIcons.paintbrush,
                    Colors.indigo,
                    () => _showThemeSelector(themeService),
                    isDark,
                  );
                },
              ),
            ], isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.systemGray,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF12121f),
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, Color color, bool value, ValueChanged<bool> onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Icon(icon, color: color, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.systemGray)),
              ],
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged, activeTrackColor: AppTheme.connectedGreen),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.systemGray)),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right, size: 18, color: AppTheme.systemGray),
          ],
        ),
      ),
    );
  }

  Future<void> _showThemeSelector(ThemeService themeService) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Theme'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              themeService.setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.device_phone_portrait, size: 20),
                const SizedBox(width: 8),
                const Text('Auto (System)'),
                if (themeService.themeMode == ThemeMode.system)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, size: 20, color: AppTheme.primaryBlue),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              themeService.setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.sun_max_fill, size: 20),
                const SizedBox(width: 8),
                const Text('Light'),
                if (themeService.themeMode == ThemeMode.light)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, size: 20, color: AppTheme.primaryBlue),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              themeService.setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.moon_fill, size: 20),
                const SizedBox(width: 8),
                const Text('Dark'),
                if (themeService.themeMode == ThemeMode.dark)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, size: 20, color: AppTheme.primaryBlue),
                  ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
