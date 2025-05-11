import 'package:firebase_parking/data/models/parking_space.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class BookingFormWidget extends StatefulWidget {
  final ParkingSpace space;

  const BookingFormWidget({super.key, required this.space});

  @override
  State<BookingFormWidget> createState() => _BookingFormWidgetState();
}

class _BookingFormWidgetState extends State<BookingFormWidget> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  late TextEditingController _vehicleRegController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerPersonalNumberController;

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

  // Calculate booking duration and cost
  String get _bookingDuration {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);

    final end = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);

    final difference = end.difference(start);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    return '$hours hour${hours != 1 ? 's' : ''} $minutes minute${minutes != 1 ? 's' : ''}';
  }

  double get _totalCost {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);

    final end = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);

    final difference = end.difference(start);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    // Calculate cost based on hourly rate
    double cost = hours * widget.space.hourlyRate;

    // Add partial hour if there are minutes
    if (minutes > 0) {
      cost += (minutes / 60) * widget.space.hourlyRate;
    }

    return cost;
  }

  @override
  void initState() {
    super.initState();
    _vehicleRegController = TextEditingController();
    _vehicleTypeController = TextEditingController();
    _ownerNameController = TextEditingController();
    _ownerPersonalNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _vehicleRegController.dispose();
    _vehicleTypeController.dispose();
    _ownerNameController.dispose();
    _ownerPersonalNumberController.dispose();
    super.dispose();
  }

  // Date/time pickers
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        // If end date is before new start date, update it
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _startTime);

    if (picked != null && mounted) {
      setState(() {
        _startTime = picked;

        // If start and end dates are the same, and end time is before start time
        if (_startDate.year == _endDate.year && _startDate.month == _endDate.month && _startDate.day == _endDate.day && _endTime.hour < _startTime.hour) {
          _endTime = TimeOfDay(hour: _startTime.hour + 1, minute: _startTime.minute);
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _endDate, firstDate: _startDate, lastDate: _startDate.add(const Duration(days: 30)));

    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _endTime);

    if (picked != null && mounted) {
      setState(() {
        _endTime = picked;

        // If end time is before start time on the same day, adjust end time
        if (_startDate.year == _endDate.year && _startDate.month == _endDate.month && _startDate.day == _endDate.day && _endTime.hour < _startTime.hour) {
          _endTime = TimeOfDay(hour: _startTime.hour + 1, minute: _startTime.minute);
        }
      });
    }
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      // Just capture the form data for now
      final Map<String, dynamic> bookingData = {
        'space': widget.space.id,
        'vehicle': {'registration': _vehicleRegController.text, 'type': _vehicleTypeController.text},
        'owner': {'name': _ownerNameController.text, 'personalNumber': _ownerPersonalNumberController.text},
        'startTime': DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute),
        'endTime': DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute),
        'totalCost': _totalCost,
      };

      // Just print the data for now during UI development
      // ignore: avoid_print
      print('Booking data collected: $bookingData');

      //  : In the future, this will connect to a repository or service
      // bookingService.createBooking(bookingData);

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking confirmed for Space ${widget.space.spaceNumber}')));

      // Navigate back
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('E, MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Text('◀️', style: TextStyle(fontSize: 22)), onPressed: () => Navigator.of(context).pop()),
        title: Text('Book Space ${widget.space.spaceNumber}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Space Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Space Details', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(_getTypeEmoji(widget.space.type), style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSecondaryContainer)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Space ${widget.space.spaceNumber}', style: Theme.of(context).textTheme.titleSmall),
                              Text('Section ${widget.space.section}, Level ${widget.space.level ?? 'G'}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Text('\$${widget.space.hourlyRate.toStringAsFixed(2)}/hr', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Vehicle Information
            Text('Vehicle Information', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // Registration Number
            TextFormField(
              controller: _vehicleRegController,
              decoration: InputDecoration(
                labelText: 'Registration Number',
                hintText: 'E.g. ABC123',
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🚗', style: TextStyle(fontSize: 20))),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter registration number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Vehicle Type
            TextFormField(
              controller: _vehicleTypeController,
              decoration: InputDecoration(
                labelText: 'Vehicle Type',
                hintText: 'E.g. Sedan, SUV, etc.',
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🚙', style: TextStyle(fontSize: 20))),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle type';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Owner Information
            Text('Owner Information', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // Owner Name
            TextFormField(
              controller: _ownerNameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('👤', style: TextStyle(fontSize: 20))),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter owner name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Personal Number
            TextFormField(
              controller: _ownerPersonalNumberController,
              decoration: InputDecoration(
                labelText: 'Personal Number',
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🆔', style: TextStyle(fontSize: 20))),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter personal number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Booking Time Information
            Text('Booking Duration', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // Start Date & Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('📅', style: TextStyle(fontSize: 20))),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(dateFormat.format(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectStartTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🕒', style: TextStyle(fontSize: 20))),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // End Date & Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('📅', style: TextStyle(fontSize: 20))),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(dateFormat.format(_endDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🕒', style: TextStyle(fontSize: 20))),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Booking Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking Summary', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Duration:'), Text(_bookingDuration, style: const TextStyle(fontWeight: FontWeight.bold))],
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Rate:'), Text('\$${widget.space.hourlyRate.toStringAsFixed(2)}/hour')]),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Cost:', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$${_totalCost.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _submitBooking,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Text('✅', style: TextStyle(fontSize: 20)), SizedBox(width: 8), Text('Confirm Booking', style: TextStyle(fontSize: 16))],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to get emoji for space type
  String _getTypeEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'handicapped':
        return '♿';
      case 'compact':
        return '🚗';
      case 'electric':
        return '🔌';
      default:
        return 'P';
    }
  }
}
