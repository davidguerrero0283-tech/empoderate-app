
import '../models/checklist_model.dart';
import 'dart:math';

/// Engine to calculate overall business progress based on weighted areas.
/// Weights: Start 40%, Payroll 20%, Accounting 20%, Marketing 20%.
class BusinessProgressEngine {
  
  static BusinessProgressModel buildSummary({
    required List<ChecklistItem> startItems,
    required List<ChecklistItem> payrollItems,
    required List<ChecklistItem> accountingItems,
    required List<ChecklistItem> marketingItems,
  }) {
    // 1. Calculate Per-Area Progress
    final start = _calculateArea(startItems, isStart: true); // Special check for Start
    final payroll = _calculateArea(payrollItems);
    final accounting = _calculateArea(accountingItems);
    final marketing = _calculateArea(marketingItems);

    // 2. Weights
    // If configured=false, contribution is 0.
    final double startW = 0.40;
    final double othersW = 0.20;

    double overallPercent = 0.0;
    
    // Only contribute if configured AND has progress
    // Wait, prompt says: "Start 40%... Overall = sum(weights * percents)"
    // If configured=false, percent is 0, so it works naturally.
    
    overallPercent += (start.percent * startW);
    overallPercent += (payroll.percent * othersW);
    overallPercent += (accounting.percent * othersW);
    overallPercent += (marketing.percent * othersW);

    // Clamp 0..1
    overallPercent = min(max(overallPercent, 0.0), 1.0);


    // Determines "Next Step" based on Priority
    // We want the HIGHEST priority pending item from the most important area.
    // Importance: Start (40) > Payroll (20) = Accounting (20) = Marketing (20).
    
    ChecklistItem? bestNext;

    // Helper to check candidate
    void checkCandidate_internal(ProgressSummary summary, List<ChecklistItem> items) {
       if (summary.percent >= 1.0) return;
       // Filter pending
       final pending = items.where((i) => !i.done).toList();
       if (pending.isEmpty) return;
       
       // Sort by Priority Descending (5 first), then Order Ascending
       pending.sort((a, b) {
          final p = b.priority.compareTo(a.priority);
          if (p != 0) return p;
          return a.order.compareTo(b.order);
       });
       
       final candidate = pending.first;
       
       if (bestNext == null) {
         bestNext = candidate;
       } else {
         // If current candidate has higher priority than bestNext, take it?
         // But we also care about Area weight.
         // Let's assume Start Area always wins if priority is Equal or Higher?
         // Actually, simpler logic: 
         // Global list of all pending items -> Sort by AreaWeight -> Priority -> Order.
       }
    }
    
    // Better Approach: Collect ALL pending items from all areas
    final allPending = <ChecklistItem>[];
    if (start.percent < 1.0) allPending.addAll(startItems.where((i) => !i.done));
    if (payroll.percent < 1.0) allPending.addAll(payrollItems.where((i) => !i.done));
    if (accounting.percent < 1.0) allPending.addAll(accountingItems.where((i) => !i.done));
    if (marketing.percent < 1.0) allPending.addAll(marketingItems.where((i) => !i.done));

    if (allPending.isNotEmpty) {
      allPending.sort((a, b) {
         // 1. Area Weight (Start is 4, others 2)
         final wA = (a.area == ProgressArea.start) ? 4 : 2;
         final wB = (b.area == ProgressArea.start) ? 4 : 2;
         if (wA != wB) return wB.compareTo(wA); // Higher weight first
         
         // 2. Priority (High first)
         if (a.priority != b.priority) return b.priority.compareTo(a.priority);
         
         // 3. Order (Low first)
         return a.order.compareTo(b.order);
      });
      bestNext = allPending.first;
    }

    final nextTitle = bestNext?.title ?? "¡Todo listo!";

    return BusinessProgressModel(
      overall: ProgressSummary(
        percent: overallPercent,
        done: start.done + payroll.done + accounting.done + marketing.done,
        total: start.total + payroll.total + accounting.total + marketing.total,
        nextTitle: nextTitle,
        configured: true, 
      ),
      byArea: {
        ProgressArea.start: start,
        ProgressArea.payroll: payroll,
        ProgressArea.accounting: accounting,
        ProgressArea.marketing: marketing,
      },
      updatedAt: DateTime.now(),
    );
  }

  static ProgressSummary _calculateArea(List<ChecklistItem> items, {bool isStart = false}) {
    if (items.isEmpty) return ProgressSummary.empty;

    final total = items.length; // Should be 10 now
    final done = items.where((i) => i.done).length;
    final percent = total > 0 ? (done / total) : 0.0;
    
    // Configured logic: If 0 progress, still return stats but maybe configured=false?
    // User wants "x/10". So let's return configured=true to show the bar empty
    // unless strictly no data? Prompt 76C implying we always show "x/10".
    // "Muestre 4 mini barras con x/10" implies we always show it.
    
    return ProgressSummary(
      percent: percent,
      done: done,
      total: total,
      configured: true, 
      nextTitle: null, // Calculated globally now
      nextRoute: null,
    );
  }
}
