import 'package:flutter/material.dart';

// Color constants for consistent theming
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kSecondaryColor = Color(0xFF00D4FF);
const Color kSuccessColor = Color(0xFF00C853);
const Color kErrorColor = Color(0xFFD32F2F);
const Color kWarningColor = Color(0xFFFFA726);
const Color kTextPrimaryColor = Color(0xFF2C2C2C);
const Color kTextSecondaryColor = Color(0xFF7A7A7A);
const Color kNeutralColor = Color(0xFFF5F5F5);

class StateManagementDemo extends StatefulWidget {
  const StateManagementDemo({super.key});

  @override
  State<StateManagementDemo> createState() => _StateManagementDemoState();
}

class _StateManagementDemoState extends State<StateManagementDemo> {
  // Local state variables
  int _counter = 0;
  int _history = 0;
  bool _isMaxReached = false;
  List<String> _actionLog = [];

  // Constants for thresholds
  static const int _MAX_COUNT = 10;
  static const int _WARNING_THRESHOLD = 5;

  /// Increment counter and update state
  void _incrementCounter() {
    setState(() {
      if (_counter < _MAX_COUNT) {
        _counter++;
        _history++;
        _actionLog.add('Incremented to $_counter');
        _checkThreshold();
      } else {
        _isMaxReached = true;
        _actionLog.add('Max count reached! (limit: $_MAX_COUNT)');
      }
    });
  }

  /// Decrement counter and update state
  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
        _actionLog.add('Decremented to $_counter');
        _checkThreshold();
      }
    });
  }

  /// Reset counter to 0
  void _resetCounter() {
    setState(() {
      _counter = 0;
      _isMaxReached = false;
      _actionLog.clear();
      _actionLog.add('Counter reset to 0');
    });
  }

  /// Check if threshold has been crossed
  void _checkThreshold() {
    _isMaxReached = _counter >= _MAX_COUNT;
  }

  /// Get background color based on counter value
  Color _getBackgroundColor() {
    if (_counter >= _WARNING_THRESHOLD) {
      return kSuccessColor.withOpacity(0.1);
    }
    return kNeutralColor;
  }

  /// Get counter text color based on value
  Color _getCounterTextColor() {
    if (_counter >= _MAX_COUNT) {
      return kErrorColor;
    } else if (_counter >= _WARNING_THRESHOLD) {
      return kSuccessColor;
    }
    return kPrimaryColor;
  }

  /// Get progress bar color based on counter value
  Color _getProgressBarColor() {
    if (_counter >= _MAX_COUNT) {
      return kErrorColor;
    } else if (_counter >= _WARNING_THRESHOLD) {
      return kWarningColor;
    }
    return kPrimaryColor;
  }

  /// Build header section with title
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'State Management with setState',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn how to manage local state dynamically',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kTextSecondaryColor,
                ) ?? const TextStyle(fontSize: 14, color: kTextSecondaryColor),
          ),
        ],
      ),
    );
  }

  /// Build counter display section
  Widget _buildCounterDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getCounterTextColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Button Pressed',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: kTextSecondaryColor,
                ) ?? const TextStyle(fontSize: 16, color: kTextSecondaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            '$_counter times',
            style: TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.bold,
              color: _getCounterTextColor(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _counter >= _MAX_COUNT
                ? '🔴 Maximum reached!'
                : _counter >= _WARNING_THRESHOLD
                    ? '🟡 Approaching limit'
                    : '✓ Normal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getCounterTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build progress indicator
  Widget _buildProgressIndicator() {
    double progress = _counter / _MAX_COUNT;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress to Limit',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ) ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              minHeight: 8,
              backgroundColor: kNeutralColor,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressBarColor()),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_counter / $_MAX_COUNT',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kTextSecondaryColor,
                ) ?? const TextStyle(fontSize: 12, color: kTextSecondaryColor),
          ),
        ],
      ),
    );
  }

  /// Build button row
  Widget _buildButtonRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement button
              ElevatedButton.icon(
                onPressed: _counter > 0 ? _decrementCounter : null,
                icon: const Icon(Icons.remove),
                label: const Text('Decrease'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kErrorColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Increment button
              ElevatedButton.icon(
                onPressed: _counter < _MAX_COUNT ? _incrementCounter : null,
                icon: const Icon(Icons.add),
                label: const Text('Increase'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccessColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Reset button
          OutlinedButton.icon(
            onPressed: _resetCounter,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Counter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryColor,
              side: const BorderSide(color: kPrimaryColor, width: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build statistics section
  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSecondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSecondaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Current',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kTextSecondaryColor,
                    ) ?? const TextStyle(fontSize: 12, color: kTextSecondaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: kTextSecondaryColor.withOpacity(0.3),
          ),
          Column(
            children: [
              Text(
                'Total Actions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kTextSecondaryColor,
                    ) ?? const TextStyle(fontSize: 12, color: kTextSecondaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                '$_history',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: kSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: kTextSecondaryColor.withOpacity(0.3),
          ),
          Column(
            children: [
              Text(
                'Remaining',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: kTextSecondaryColor,
                    ) ?? const TextStyle(fontSize: 12, color: kTextSecondaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                '${_MAX_COUNT - _counter}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _counter >= _MAX_COUNT ? kErrorColor : kSuccessColor,
                      fontWeight: FontWeight.bold,
                    ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build action log section
  Widget _buildActionLog() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kNeutralColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kTextSecondaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action History',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ) ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (_actionLog.isEmpty)
            Text(
              'No actions yet. Press a button to start!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kTextSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ) ?? const TextStyle(
                fontSize: 12,
                color: kTextSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              child: ListView.builder(
                shrinkWrap: true,
                reverse: true,
                itemCount: _actionLog.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _actionLog[_actionLog.length - 1 - index],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: kTextPrimaryColor,
                                ) ?? const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management Demo'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeaderSection(),

            // Counter display
            _buildCounterDisplay(),

            // Progress indicator
            _buildProgressIndicator(),

            // Buttons
            _buildButtonRow(),

            // Statistics
            _buildStatisticsSection(),

            // Action log
            _buildActionLog(),

            // Bottom spacing
            const SizedBox(height: 24),

            // Key concepts section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How setState() Works',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ) ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildKeyPoint('1. setState() marks widget as dirty',
                      'The widget rebuilds to reflect state changes'),
                  const SizedBox(height: 8),
                  _buildKeyPoint('2. Local variables store state',
                      '_counter holds the current value'),
                  const SizedBox(height: 8),
                  _buildKeyPoint('3. Conditional updates',
                      'Logic determines how UI responds to state'),
                  const SizedBox(height: 8),
                  _buildKeyPoint('4. Efficient rebuilds',
                      'Only affected widgets rebuild, not entire app'),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Helper widget for key points
  Widget _buildKeyPoint(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: kTextPrimaryColor,
              ) ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kTextSecondaryColor,
              ) ?? const TextStyle(fontSize: 12, color: kTextSecondaryColor),
        ),
      ],
    );
  }
}
