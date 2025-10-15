import 'package:flutter/material.dart';

// Pantalla principal para el cuidador que permite:
//  - Ingresar el código numérico de un paciente.
//  - Definir horarios de rutina (ej. cena y baño) para el paciente.
// Esta pantalla es Stateful porque mantiene estado local (código, horarios, formulario).
class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  // Código que escribe el usuario (sin controlador)
  String _inputCode = '';

  // Código confirmado; si es null se muestra la pantalla de ingreso
  String? _patientCode;

  // Horarios simples
  TimeOfDay? _dinnerTime;
  TimeOfDay? _bathTime;

  // Método para confirmar el código (sin validaciones)
  void _submitPatientCode() {
    setState(() {
      _patientCode = _inputCode.trim();
    });
  }

  // Guardar rutina
  void _submitRoutine() {
    setState(() {
      // Para luego
    });
  }

  // Pequeña ayuda para mostrar la hora con el formato local o '--:--'
  String _timeText(TimeOfDay? t, BuildContext ctx) => t?.format(ctx) ?? '--:--';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home cuidador')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _patientCode == null ? _buildPatientCodeInput() : _buildRoutineForm(),
      ),
    );
  }

  // UI para ingresar el código
  Widget _buildPatientCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Ingrese el código del paciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (v) => _inputCode = v,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Código numérico del paciente',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _submitPatientCode, child: const Text('Aceptar')),
      ],
    );
  }

  // Formulario mínimo para seleccionar horas
  Widget _buildRoutineForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Agregue la rutina del paciente (código: $_patientCode)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),

        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Cena'),
          subtitle: Text(_timeText(_dinnerTime, context)),
          trailing: TextButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _dinnerTime ?? TimeOfDay.now(),
              );
              if (picked != null) setState(() => _dinnerTime = picked);
            },
            child: const Text('Seleccionar'),
          ),
        ),

        const Divider(),

        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Baño'),
          subtitle: Text(_timeText(_bathTime, context)),
          trailing: TextButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _bathTime ?? TimeOfDay.now(),
              );
              if (picked != null) setState(() => _bathTime = picked);
            },
            child: const Text('Seleccionar'),
          ),
        ),

        const SizedBox(height: 24),
        ElevatedButton(onPressed: _submitRoutine, child: const Text('Guardar rutina')),

        const SizedBox(height: 16),
        if (_dinnerTime != null || _bathTime != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rutina actual', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Cena: ${_timeText(_dinnerTime, context)}'),
                  Text('Baño: ${_timeText(_bathTime, context)}'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}