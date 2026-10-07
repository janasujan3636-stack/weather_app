import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_report_model.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_container.dart';
import 'add_report_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchCommunityReports();
    });
  }

  void _showEditDialog(BuildContext context, WeatherReportModel report) {
    final notesController = TextEditingController(text: report.notes);
    final tempController = TextEditingController(text: report.temperature.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF152238),
        title: Text(
          'Edit Observation (${report.city})',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tempController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Temperature (°C)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Observation Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D2FF)),
            onPressed: () async {
              final newTemp = double.tryParse(tempController.text) ?? report.temperature;
              final updated = report.copyWith(
                temperature: newTemp,
                notes: notesController.text.trim(),
              );
              Navigator.pop(ctx);
              final success = await Provider.of<WeatherProvider>(context, listen: false)
                  .updateWeatherReport(updated);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Report updated via REST PUT!'
                        : 'Failed to update report'),
                    backgroundColor: success ? Colors.teal.shade700 : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Save (PUT)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF152238),
        title: const Text('Delete Observation', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to remove this report? This will execute REST DELETE on the backend.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await Provider.of<WeatherProvider>(context, listen: false)
                  .deleteWeatherReport(id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Observation deleted via REST DELETE!'
                        : 'Failed to delete report'),
                    backgroundColor: success ? Colors.teal.shade700 : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WeatherProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Cloud Weather Feed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Reports (GET)',
            onPressed: () => prov.fetchCommunityReports(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00D2FF),
        foregroundColor: const Color(0xFF0F2027),
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('New Observation', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReportScreen()),
          );
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: prov.communityReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 64, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(height: 14),
                      Text(
                        'No weather observations yet',
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap the button below to upload your first sky photo',
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: const Color(0xFF1E3C72),
                  onRefresh: () => prov.fetchCommunityReports(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    itemCount: prov.communityReports.length,
                    itemBuilder: (context, index) {
                      final report = prov.communityReports[index];
                      return GlassContainer(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cloud-stored image header
                            if (report.imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      report.imageUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 140,
                                        color: Colors.white.withOpacity(0.1),
                                        child: const Center(
                                          child: Icon(Icons.broken_image, color: Colors.white54),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.65),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.cloud_done_rounded, color: Color(0xFF00D2FF), size: 14),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Firebase Storage',
                                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Details & Content
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 18, color: Color(0xFF00D2FF)),
                                          const SizedBox(width: 4),
                                          Text(
                                            report.city,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${report.temperature.round()}°C • ${report.condition}',
                                          style: const TextStyle(
                                            color: Colors.amberAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    report.notes,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.85),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'By ${report.author} • ${report.createdAt.hour}:${report.createdAt.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF00D2FF)),
                                            tooltip: 'Edit (REST PUT)',
                                            onPressed: () => _showEditDialog(context, report),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                            tooltip: 'Delete (REST DELETE)',
                                            onPressed: () => _confirmDelete(context, report.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
