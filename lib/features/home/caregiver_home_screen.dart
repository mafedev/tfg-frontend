import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/app_colors.dart';
import 'rutine_service.dart';

// Pantalla principal para el cuidador que permite:
//  - Ingresar el código numérico de un paciente.
//  - Definir horarios de rutina y de medicación
class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  // Código que escribe el usuario (sin controlador)
  String _inputCode = '';

  // Código
  String? _patientCode;

  // Horarios de comida
  TimeOfDay? _breakfastTime;
  TimeOfDay? _lunchTime;
  TimeOfDay? _dinnerTime;
  TimeOfDay? _bathTime;

  // Hidratación: activar recordatorios y intervalo en horas
  bool _enableHydrationReminders = false;
  int? _hydrationIntervalHours;

  // indicador de guardado
  bool _isSaving = false;

  // Método para confirmar el código (sin validaciones)
  void _submitPatientCode() {
    setState(() {
      _patientCode = _inputCode.trim();
      if(_patientCode!.isEmpty) {
        _patientCode = null; // No aceptar códigos vacíos
      }
    });
  }

  // Guardar rutina
  Future<void> _submitRoutine() async {
    if (_isSaving) return; // evitar reentradas
    setState(() => _isSaving = true);

    final service = RutineService();
    final success = await service.saveRutine(
      _breakfastTime,
      _lunchTime,
      _dinnerTime,
      _bathTime,
      _enableHydrationReminders,
      _hydrationIntervalHours,
    );

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Rutina guardada correctamente' : 'Error al guardar la rutina'),
      ),
    );
  }

  // Muestra '--:--'
  String _timeText(TimeOfDay? t, BuildContext ctx) => t?.format(ctx) ?? '--:--';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home cuidador'), backgroundColor: AppColors.primary,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _patientCode == null
            ? _buildPatientCodeInput()
            : _buildRoutineForm(),
      ),
    );
  }

  // Ingresar el código del paciente
  Widget _buildPatientCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Ingrese el código del paciente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (v) => _inputCode = v, // Actualiza el valor
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Código del paciente',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _submitPatientCode,
          child: const Text('Aceptar'),
        ),
      ],
    );
  }

  // Formulario para ingresar la rutina
  Widget _buildRoutineForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Agregue la rutina del paciente Nombre($_patientCode)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Text(
          'Horarios de Comida',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Llama al método helper para cada horario
        // Comidas
        _buildTimePickerTile(
          title: 'Desayuno',
          time: _breakfastTime,
          onChanged: (picked) => setState(() => _breakfastTime = picked),
        ),

        const Divider(),

        _buildTimePickerTile(
          title: 'Almuerzo',
          time: _lunchTime,
          onChanged: (picked) => setState(() => _lunchTime = picked),
        ),

        const Divider(),

        _buildTimePickerTile(
          title: 'Cena',
          time: _dinnerTime,
          onChanged: (picked) => setState(() => _dinnerTime = picked),
        ),

        const Divider(),

        _buildTimePickerTile(
          title: 'Baño',
          time: _bathTime,
          onChanged: (picked) => setState(() => _bathTime = picked),
        ),

        const Divider(),

        // Recordatorios de hidratación
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Desea agregar recordatorios para tomar agua'),
          value: _enableHydrationReminders,
          onChanged: (v) => setState(() => _enableHydrationReminders = v),
        ),
        if (_enableHydrationReminders)
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Row(
              children: [
                const Text('Intervalo:'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _hydrationIntervalHours,
                  hint: const Text('Seleccione intervalo'),
                  items: <int>[1, 2, 3].map((v) {
                    return DropdownMenuItem<int>(
                      value: v,
                      child: Text('Cada ${v}h'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _hydrationIntervalHours = v),
                ),
              ],
            ),
          ),

        // Alergías
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Alergías a algún alimento',
            border: OutlineInputBorder(),
          ),
          items: <String>[
            'Ninguna',
            'Leche de vaca',
            'Huevo',
            'Cacahuate',
            'Pescado',
            'Mariscos',
            'Soja',
            'Trigo',
            'Otros',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (v) {},
        ),

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submitRoutine,
          child: const Text('Guardar rutina'),
        ),

        const SizedBox(height: 16),
        if (_breakfastTime != null || _lunchTime != null || _dinnerTime != null || _bathTime != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rutina actual',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_breakfastTime != null) Text('Desayuno: ${_timeText(_breakfastTime, context)}'),
                  if (_lunchTime != null) Text('Almuerzo: ${_timeText(_lunchTime, context)}'),
                  if (_dinnerTime != null) Text('Cena: ${_timeText(_dinnerTime, context)}'),
                  if (_bathTime != null) Text('Baño: ${_timeText(_bathTime, context)}'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Nuevo helper para construir el ListTile con selector de hora
  Widget _buildTimePickerTile({
    required String title,
    required TimeOfDay? time,
    required ValueChanged<TimeOfDay?> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(_timeText(time, context)),
      trailing: TextButton(
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time ?? TimeOfDay.now(),
          );
          if (picked != null) onChanged(picked);
        },
        child: const Text('Seleccionar'),
      ),
    );
  }
}