const fs = require('fs');
const filepath = 'c:\\interview\\lib\\screens\\product_detail_screen.dart';
let content = fs.readFileSync(filepath, 'utf-8');

// 1. Add _editingInitialized flag
const old1 = 'bool _addedToBag = false;';
const new1 = 'bool _addedToBag = false;\n  bool _editingInitialized = false;';
if (content.includes(old1)) {
  content = content.replace(old1, new1);
  console.log('OK: Added _editingInitialized');
} else {
  console.log('WARN: Could not find _addedToBag line');
  process.exit(1);
}

// 2. Add _initEditingState and _updateCartItem methods before _sortedPricing
const anchor2 = '  List<ProductPricing> _sortedPricing(Product product) {';
const insertBefore2 = `  void _initEditingState(Product product) {
    if (_editingInitialized || !widget.isEditing) return;
    _editingInitialized = true;

    final meta = widget.editingMeta ?? const <String, dynamic>{};
    final cat = (widget.editingCategory ?? product.category ?? '').toUpperCase();

    // Pre-select pricing by pricingId
    if (widget.editingPricingId != null) {
      final match = product.pricing.where((p) => p.id == widget.editingPricingId);
      if (match.isNotEmpty) {
        _selectedPricing = match.first;
        final cap = _selectedPricing?.seatCapacity;
        if (cap != null && cap > 0) _people = cap;
        if (_selectedPricing!.options.isNotEmpty) {
          _selectedPricingOption = _selectedPricing!.options.first;
        }
      }
    }

    // Pre-select start time
    if (widget.editingStartTime != null) {
      final local = widget.editingStartTime!.toLocal();
      _selectedDate = DateTime(local.year, local.month, local.day);
      _selectedTime = TimeOfDay.fromDateTime(local);
    }

    // Pre-select meta fields
    if (cat == 'JET_SKI' || cat == 'JETSKI' || cat == 'JET SKI' || cat == 'JET-SKI') {
      final type = meta['type']?.toString() ?? '';
      if (type.isNotEmpty) {
        _jetSkiType = type[0].toUpperCase() + type.substring(1);
      }
    } else if (cat == 'TRANSPORTATION' || cat == 'TRANSPORT') {
      final tripType = meta['tripType']?.toString() ?? '';
      _transportType = tripType == 'NEXT_DAY' ? 'Next Day' : 'Same Day';
      _selectedRoute = meta['routes']?.toString() ?? '';

      if (meta['to'] != null) {
        final toDt = DateTime.tryParse(meta['to'].toString());
        if (toDt != null) {
          final local = toDt.toLocal();
          _toDate = DateTime(local.year, local.month, local.day);
          _toTime = TimeOfDay.fromDateTime(local);
        }
      }
      if (meta['fro'] != null) {
        final froDt = DateTime.tryParse(meta['fro'].toString());
        if (froDt != null) {
          final local = froDt.toLocal();
          _fromDate = DateTime(local.year, local.month, local.day);
          _fromTime = TimeOfDay.fromDateTime(local);
        }
      }
    } else if (cat == 'BOAT_CRUISE' || cat == 'BOATCRUISE') {
      final people = (meta['people'] as num?)?.toInt();
      if (people != null && people > 0) _people = people;
    } else {
      final people = (meta['people'] as num?)?.toInt();
      if (people != null && people > 0) _people = people;
    }
  }

  Future<void> _updateCartItem({required Product product}) async {
    final pricing = _selectedPricing;
    if (pricing == null || pricing.id.isEmpty) {
      ToastHelper.showWarning('Please select a duration');
      return;
    }

    final startTime = _startTimeIsoForCategory(product.category ?? '');
    if (startTime == null || startTime.isEmpty) {
      ToastHelper.showWarning('Please select a time');
      return;
    }

    final category = (product.category ?? '').toUpperCase();
    Map<String, dynamic> meta = <String, dynamic>{};

    if (category == 'JET_SKI' ||
        category == 'JETSKI' ||
        category == 'JET SKI' ||
        category == 'JET-SKI') {
      meta = <String, dynamic>{'type': _jetSkiType.toLowerCase()};
    } else if (category == 'TRANSPORTATION' || category == 'TRANSPORT') {
      final tripType = _transportType == 'Next Day' ? 'NEXT_DAY' : 'SAME_DAY';
      final routes = product.meta?.routes ?? const <String, int>{};
      final routeMinutes = routes[_selectedRoute.trim()];

      final toDt =
          _transportToSlot?.startTime ??
          _combine(
            _transportType == 'Next Day' ? _toDate : _selectedDate,
            _toTime,
          );
      final fromDt =
          _transportFroSlot?.startTime ??
          _combine(
            _transportType == 'Next Day' ? _fromDate : _selectedDate,
            _fromTime,
          );

      if (_selectedRoute.trim().isEmpty) {
        ToastHelper.showWarning('Please select a route');
        return;
      }
      if (toDt == null || fromDt == null) {
        ToastHelper.showWarning('Please select To and Fro times');
        return;
      }

      meta = <String, dynamic>{
        'routes': _selectedRoute.trim(),
        'tripType': tripType,
        'to': toDt.toUtc().toIso8601String(),
        'fro': fromDt.toUtc().toIso8601String(),
      };

      final durationToSend = routeMinutes ?? pricing.duration;
      await ref
          .read(cartControllerProvider.notifier)
          .updateCartItem(
            bagItemId: widget.editingBagItemId!,
            data: <String, dynamic>{
              'pricingId': pricing.id,
              'startTime': startTime,
              'duration': durationToSend.toInt(),
              'meta': meta,
            },
          );
      return;
    } else {
      if (category == 'BOAT_CRUISE' || category == 'BOATCRUISE') {
        if (pricing.options.isNotEmpty && _selectedPricingOption == null) {
          ToastHelper.showWarning('Please select a duration');
          return;
        }
        final cap = _selectedPricing?.seatCapacity;
        meta = <String, dynamic>{'people': (cap ?? _people)};
      } else {
        meta =
            _hasSeatCapacity(product)
                ? <String, dynamic>{'people': _people}
                : <String, dynamic>{};
      }
    }

    final durationToSend =
        (category == 'BOAT_CRUISE' || category == 'BOATCRUISE') &&
                pricing.options.isNotEmpty
            ? ((_selectedPricingOption?.duration ??
                    pricing.options.first.duration) *
                60)
            : pricing.duration;

    await ref
        .read(cartControllerProvider.notifier)
        .updateCartItem(
          bagItemId: widget.editingBagItemId!,
          data: <String, dynamic>{
            'pricingId': pricing.id,
            'startTime': startTime,
            'duration': durationToSend.toInt(),
            'meta': meta,
          },
        );
  }

`;

if (content.includes(anchor2)) {
  content = content.replace(anchor2, insertBefore2 + anchor2);
  console.log('OK: Added _initEditingState and _updateCartItem');
} else {
  console.log('WARN: Could not find _sortedPricing anchor');
  process.exit(1);
}

// 3. Add _initEditingState call in build method after productAsync.data
const anchor3 = "data: (product) {\n        if (product == null) {";
if (content.includes(anchor3)) {
  content = content.replace(anchor3, "data: (product) {\n        _initEditingState(product);\n        if (product == null) {");
  console.log('OK: Added _initEditingState call in build');
} else {
  console.log('WARN: Could not find data: (product) anchor');
  // Try alternative
  const anchor3b = 'data: (product) {';
  const idx = content.lastIndexOf(anchor3b);
  if (idx >= 0) {
    // Find the next line after this
    const afterAnchor = content.substring(idx + anchor3b.length);
    const nlIdx = afterAnchor.indexOf('\n');
    if (nlIdx >= 0) {
      const insertPos = idx + anchor3b.length + nlIdx + 1;
      content = content.substring(0, insertPos) + '        _initEditingState(product);\n' + content.substring(insertPos);
      console.log('OK: Added _initEditingState call (alt)');
    }
  }
}

// 4. Replace bottom navigation bar buttons: when editing, show single Update button
const oldButtons = `                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Add to Bag',`;
const newButtons = `                  if (widget.isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: 'Update',
                        isLoading: _isBooking,
                        onPressed: () async {
                          if (_isBooking || _isPaying) return;
                          setState(() {
                            _isBooking = true;
                          });
                          try {
                            await _updateCartItem(product: product);
                            ref.invalidate(cartItemsProvider);
                            ToastHelper.showSuccess('Cart item updated');
                            if (mounted) Navigator.of(context).pop();
                          } catch (e) {
                            final msg =
                                e is ApiException ? e.message : e.toString();
                            ToastHelper.showError(msg);
                          } finally {
                            if (!mounted) return;
                            setState(() {
                              _isBooking = false;
                            });
                          }
                        },
                      ),
                    )
                  else
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Add to Bag',`;

if (content.includes(oldButtons)) {
  content = content.replace(oldButtons, newButtons);
  console.log('OK: Added Update button for edit mode');
} else {
  console.log('WARN: Could not find bottom buttons anchor');
}

fs.writeFileSync(filepath, content, 'utf-8');
console.log('All edits written successfully.');
