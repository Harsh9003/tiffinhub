import 'package:flutter/material.dart';

import '../services/customer_service.dart';

class AddressChangeRequestPage extends StatefulWidget {
  const AddressChangeRequestPage({super.key});

  @override
  State<AddressChangeRequestPage> createState() => _AddressChangeRequestPageState();
}

class _AddressChangeRequestPageState extends State<AddressChangeRequestPage> {
  static const Color _bg = Color(0xFFFFFBF7);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _softOrange = Color(0xFFFFF0E4);
  static const Color _text = Color(0xFF241A14);
  static const Duration _cancellationWindow = Duration(hours: 2);

  final TextEditingController _noteController = TextEditingController();
  CustomerAddressModel? _selectedAddress;
  bool _isSubmitting = false;
  bool _noteError = false;
  String? _cancellingRequestId;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final selected = _selectedAddress;
    final note = _noteController.text.trim();

    if (selected == null) {
      _showMessage('Please select a new delivery address before submitting your request.');
      return;
    }

    if (note.isEmpty) {
      setState(() => _noteError = true);
      _showMessage('Please provide a reason for the address change request.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await CustomerService.sendAddressChangeRequest(
        address: selected,
        note: note,
      );

      if (!mounted) return;
      _noteController.clear();
      setState(() {
        _selectedAddress = null;
        _noteError = false;
      });
      _showMessage('Address change request submitted successfully.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to submit the request. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _cancelRequest(CustomerAddressChangeRequestModel request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Cancel Address Change Request'),
          content: const Text(
            'This request will be cancelled and will not be sent for restaurant review.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Request'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Request'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _cancellingRequestId = request.id);

    try {
      await CustomerService.cancelAddressChangeRequest(request.id);
      if (!mounted) return;
      _showMessage('Address change request cancelled successfully.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to cancel the request. Please try again.');
    } finally {
      if (mounted) setState(() => _cancellingRequestId = null);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
                children: [
                  const _InfoBanner(),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: 'Select New Delivery Address'),
                  const SizedBox(height: 10),
                  StreamBuilder<List<CustomerAddressModel>>(
                    stream: CustomerService.watchAddresses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _LoadingBox(message: 'Loading saved addresses...');
                      }

                      final addresses = snapshot.data ?? [];
                      if (addresses.isEmpty) {
                        return const _EmptyBox(
                          title: 'No saved addresses found',
                          message: 'Please add a delivery address before creating a change request.',
                        );
                      }

                      return Column(
                        children: addresses.map((address) {
                          final isSelected = _selectedAddress?.id == address.id;
                          return _AddressOptionCard(
                            address: address,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedAddress = address),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: 'Reason for Address Change'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                    onChanged: (value) {
                      if (_noteError && value.trim().isNotEmpty) {
                        setState(() => _noteError = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Provide the reason for requesting a new delivery address.',
                      hintStyle: TextStyle(color: Colors.brown.shade300, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      errorText: _noteError ? 'Reason is required.' : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(
                          color: _noteError ? Colors.red : _orange.withOpacity(0.18),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(
                          color: _noteError ? Colors.red : _orange,
                          width: 1.4,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: Colors.red, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle(title: 'Recent Requests'),
                  const SizedBox(height: 10),
                  StreamBuilder<List<CustomerAddressChangeRequestModel>>(
                    stream: CustomerService.watchAddressChangeRequests(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _LoadingBox(message: 'Loading recent requests...');
                      }

                      final requests = snapshot.data ?? [];
                      if (requests.isEmpty) {
                        return const _EmptyBox(
                          title: 'No address change requests',
                          message: 'Your submitted requests will appear here.',
                        );
                      }

                      return Column(
                        children: requests.map((request) {
                          return _RequestStatusCard(
                            request: request,
                            cancellationWindow: _cancellationWindow,
                            isCancelling: _cancellingRequestId == request.id,
                            onCancel: () => _cancelRequest(request),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSubmitting ? null : _submitRequest,
        backgroundColor: _orange,
        foregroundColor: Colors.white,
        elevation: 10,
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(
          _isSubmitting ? 'Submitting...' : 'Submit Request',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 18, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Expanded(
            child: Text(
              'Address Change Request',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _AddressChangeRequestPageState._text,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6A00), Color(0xFFFF8A21)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _AddressChangeRequestPageState._orange.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.location_on_rounded, color: Color(0xFFFF6A00)),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request New Delivery Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You can cancel a new request within two hours. After that, it moves to initial review.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _AddressChangeRequestPageState._text,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AddressOptionCard extends StatelessWidget {
  final CustomerAddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressOptionCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? _AddressChangeRequestPageState._orange
                : _AddressChangeRequestPageState._orange.withOpacity(0.18),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _AddressChangeRequestPageState._softOrange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _iconForAddress(address.title),
                color: _AddressChangeRequestPageState._orange,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.title,
                          style: const TextStyle(
                            color: _AddressChangeRequestPageState._text,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (address.isDefault)
                        _SmallBadge(
                          label: 'Primary',
                          color: _AddressChangeRequestPageState._orange,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _contactLine(address),
                    style: const TextStyle(
                      color: _AddressChangeRequestPageState._text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _addressLine(address),
                    style: TextStyle(
                      color: Colors.brown.shade400,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? _AddressChangeRequestPageState._orange
                  : Colors.brown.shade200,
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForAddress(String title) {
    final value = title.toLowerCase();
    if (value.contains('office') || value.contains('work')) return Icons.business_rounded;
    if (value.contains('other')) return Icons.location_on_rounded;
    return Icons.home_rounded;
  }

  static String _contactLine(CustomerAddressModel address) {
    final name = address.receiverName.trim();
    final phone = address.phone.trim();
    if (name.isNotEmpty && phone.isNotEmpty) return '$name • $phone';
    if (name.isNotEmpty) return name;
    if (phone.isNotEmpty) return phone;
    return 'Contact details not provided';
  }

  static String _addressLine(CustomerAddressModel address) {
    final parts = [
      address.addressLine,
      address.landmark,
      address.city,
      address.pincode,
    ].where((item) => item.trim().isNotEmpty).toList();
    return parts.join(', ');
  }
}

class _RequestStatusCard extends StatelessWidget {
  final CustomerAddressChangeRequestModel request;
  final Duration cancellationWindow;
  final bool isCancelling;
  final VoidCallback onCancel;

  const _RequestStatusCard({
    required this.request,
    required this.cancellationWindow,
    required this.isCancelling,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = request.createdAt?.toDate();
    final now = DateTime.now();
    final isPending = request.status == 'pending';
    final isCancelled = request.status == 'cancelled_by_customer';
    final canCancel = isPending && createdAt != null && now.difference(createdAt) < cancellationWindow;
    final stageData = _stageData(request.status, createdAt, cancellationWindow);
    final remaining = createdAt == null
        ? Duration.zero
        : cancellationWindow - now.difference(createdAt);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stageData.color.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(stageData.icon, color: stageData.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.title,
                  style: const TextStyle(
                    color: _AddressChangeRequestPageState._text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _SmallBadge(label: stageData.label, color: stageData.color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _addressLine(request),
            style: TextStyle(
              color: Colors.brown.shade400,
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _RequestStageTimeline(
            status: request.status,
            createdAt: createdAt,
            cancellationWindow: cancellationWindow,
          ),
          const SizedBox(height: 12),
          Text(
            stageData.description,
            style: TextStyle(
              color: Colors.brown.shade500,
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (canCancel) ...[
            const SizedBox(height: 8),
            Text(
              'Cancellation window: ${_formatRemainingTime(remaining)} remaining',
              style: const TextStyle(
                color: Color(0xFFB45309),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isCancelling ? null : onCancel,
                icon: isCancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.close_rounded, size: 18),
                label: Text(isCancelling ? 'Cancelling...' : 'Cancel Request'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
          if (request.customerNote.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Customer Note: ${request.customerNote.trim()}',
              style: TextStyle(
                color: Colors.brown.shade500,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (request.status == 'rejected' && request.rejectionReason.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Restaurant Response: ${request.rejectionReason.trim()}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (isCancelled) ...[
            const SizedBox(height: 8),
            const Text(
              'This request was cancelled by you and will not be reviewed by the restaurant.',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _addressLine(CustomerAddressChangeRequestModel request) {
    final parts = [
      request.addressLine,
      request.landmark,
      request.city,
      request.pincode,
    ].where((item) => item.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  static _StatusData _stageData(String status, DateTime? createdAt, Duration window) {
    final isReviewStarted = createdAt != null && DateTime.now().difference(createdAt) >= window;

    switch (status) {
      case 'approved':
        return const _StatusData(
          label: 'Approved',
          color: Color(0xFF16A34A),
          icon: Icons.verified_rounded,
          description: 'The restaurant has approved this address change request.',
        );
      case 'rejected':
        return const _StatusData(
          label: 'Rejected',
          color: Color(0xFFEF4444),
          icon: Icons.cancel_rounded,
          description: 'The restaurant has rejected this address change request.',
        );
      case 'cancelled_by_customer':
        return const _StatusData(
          label: 'Cancelled',
          color: Color(0xFFDC2626),
          icon: Icons.block_rounded,
          description: 'This request was cancelled before restaurant review started.',
        );
      default:
        if (isReviewStarted) {
          return const _StatusData(
            label: 'Initial Review',
            color: Color(0xFF2563EB),
            icon: Icons.manage_search_rounded,
            description: 'The cancellation window has ended. This request is now ready for restaurant review.',
          );
        }
        return const _StatusData(
          label: 'Request Submitted',
          color: Color(0xFFF59E0B),
          icon: Icons.schedule_rounded,
          description: 'You can cancel this request within two hours of submission.',
        );
    }
  }

  static String _formatRemainingTime(Duration duration) {
    final safeDuration = duration.isNegative ? Duration.zero : duration;
    final hours = safeDuration.inHours;
    final minutes = safeDuration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _RequestStageTimeline extends StatelessWidget {
  final String status;
  final DateTime? createdAt;
  final Duration cancellationWindow;

  const _RequestStageTimeline({
    required this.status,
    required this.createdAt,
    required this.cancellationWindow,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final reviewStarted = createdAt != null && now.difference(createdAt!) >= cancellationWindow;
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';
    final isCancelled = status == 'cancelled_by_customer';

    final stages = [
      _StageItem(
        label: 'Request Submitted',
        isActive: status == 'pending' && !reviewStarted,
        isCompleted: status != 'cancelled_by_customer',
      ),
      _StageItem(
        label: 'Initial Review',
        isActive: status == 'pending' && reviewStarted,
        isCompleted: reviewStarted || isApproved || isRejected,
      ),
      _StageItem(
        label: isCancelled
            ? 'Cancelled'
            : isApproved
                ? 'Approved'
                : isRejected
                    ? 'Rejected'
                    : 'Restaurant Decision',
        isActive: isApproved || isRejected || isCancelled,
        isCompleted: isApproved || isRejected || isCancelled,
      ),
    ];

    return Row(
      children: List.generate(stages.length, (index) {
        final item = stages[index];
        return Expanded(
          child: Row(
            children: [
              Expanded(child: _StagePill(item: item)),
              if (index != stages.length - 1)
                Container(
                  width: 12,
                  height: 2,
                  color: item.isCompleted
                      ? _AddressChangeRequestPageState._orange.withOpacity(0.55)
                      : Colors.brown.withOpacity(0.15),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _StageItem {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StageItem({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });
}

class _StagePill extends StatelessWidget {
  final _StageItem item;

  const _StagePill({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isActive || item.isCompleted
        ? _AddressChangeRequestPageState._orange
        : Colors.brown.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(item.isActive ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(item.isActive ? 0.35 : 0.18)),
      ),
      child: Text(
        item.label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          height: 1.15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatusData {
  final String label;
  final Color color;
  final IconData icon;
  final String description;

  const _StatusData({
    required this.label,
    required this.color,
    required this.icon,
    required this.description,
  });
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  final String message;

  const _LoadingBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _AddressChangeRequestPageState._orange.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(
              color: _AddressChangeRequestPageState._text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyBox({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _AddressChangeRequestPageState._orange.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _AddressChangeRequestPageState._text,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            style: TextStyle(
              color: Colors.brown.shade400,
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
