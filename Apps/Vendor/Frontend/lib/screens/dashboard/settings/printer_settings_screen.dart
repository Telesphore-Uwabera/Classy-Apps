import 'package:flutter/material.dart';
import '../../../services/printer_service.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../constants/app_theme.dart';
import '../../../constants/app_constants.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _printerNameController = TextEditingController();
  final _printerAddressController = TextEditingController();
  
  final PrinterService _printerService = PrinterService.instance;
  
  bool _isBluetoothEnabled = false;
  bool _isNetworkEnabled = true;
  int _paperWidth = 80;
  String _fontSize = 'medium';
  bool _isLoading = false;
  List<String> _availablePrinters = [];

  @override
  void initState() {
    super.initState();
    _loadPrinterSettings();
    _loadAvailablePrinters();
  }

  @override
  void dispose() {
    _printerNameController.dispose();
    _printerAddressController.dispose();
    super.dispose();
  }

  void _loadPrinterSettings() {
    _printerNameController.text = _printerService.printerName;
    _printerAddressController.text = _printerService.printerAddress;
    _isBluetoothEnabled = _printerService.isBluetoothEnabled;
    _isNetworkEnabled = _printerService.isNetworkEnabled;
    _paperWidth = _printerService.paperWidth;
    _fontSize = _printerService.fontSize;
  }

  Future<void> _loadAvailablePrinters() async {
    final printers = await _printerService.getAvailablePrinters();
    setState(() {
      _availablePrinters = printers;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _printerService.updatePrinterSettings(
        printerName: _printerNameController.text.trim(),
        printerAddress: _printerAddressController.text.trim(),
        isBluetoothEnabled: _isBluetoothEnabled,
        isNetworkEnabled: _isNetworkEnabled,
        paperWidth: _paperWidth,
        fontSize: _fontSize,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Printer settings saved successfully')),
          );
        }
      } else {
        throw Exception('Failed to save printer settings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _printerService.testPrinterConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Printer connection successful!' : 'Printer connection failed'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error testing connection: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Printer Configuration Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Printer Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Printer Name
                      CustomTextField(
                        controller: _printerNameController,
                        labelText: 'Printer Name',
                        hintText: 'Enter printer name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter printer name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Printer Address
                      CustomTextField(
                        controller: _printerAddressController,
                        labelText: 'Printer Address',
                        hintText: 'IP address or Bluetooth address',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter printer address';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Connection Type
                      const Text(
                        'Connection Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      SwitchListTile(
                        title: const Text('Bluetooth'),
                        subtitle: const Text('Connect via Bluetooth'),
                        value: _isBluetoothEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isBluetoothEnabled = value;
                            if (value) _isNetworkEnabled = false;
                          });
                        },
                        activeThumbColor: AppTheme.primaryColor,
                      ),
                      
                      SwitchListTile(
                        title: const Text('Network'),
                        subtitle: const Text('Connect via Wi-Fi/Ethernet'),
                        value: _isNetworkEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isNetworkEnabled = value;
                            if (value) _isBluetoothEnabled = false;
                          });
                        },
                        activeThumbColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Print Settings Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Print Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Paper Width
                      const Text(
                        'Paper Width (mm)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Slider(
                        value: _paperWidth.toDouble(),
                        min: 58,
                        max: 80,
                        divisions: 11,
                        label: '${_paperWidth}mm',
                        onChanged: (value) {
                          setState(() {
                            _paperWidth = value.round();
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Font Size
                      const Text(
                        'Font Size',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      DropdownButtonFormField<String>(
                        value: _fontSize,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'small', child: Text('Small')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'large', child: Text('Large')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value ?? 'medium';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Available Printers Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Available Printers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _loadAvailablePrinters,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      if (_availablePrinters.isEmpty)
                        const Text(
                          'No printers found. Make sure your printer is connected and powered on.',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ..._availablePrinters.map((printer) => ListTile(
                          leading: const Icon(Icons.print),
                          title: Text(printer),
                          trailing: IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              _printerNameController.text = printer;
                            },
                          ),
                        )),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _testConnection,
                      icon: const Icon(Icons.wifi_protected_setup),
                      label: const Text('Test Connection'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Settings',
                      onPressed: _isLoading ? null : _saveSettings,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
