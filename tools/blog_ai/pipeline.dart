import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  print('''
╔══════════════════════════════════════════════════════════════╗
║     EMPODÉRATE - Blog AI Pipeline (Automated)                ║
╚══════════════════════════════════════════════════════════════╝
''');

  // Parse arguments
  int count = 1;
  bool autoApprove = true;
  bool buildWeb = false;

  for (final arg in args) {
    if (arg.startsWith('--count=')) {
      count = int.tryParse(arg.split('=')[1]) ?? 1;
    } else if (arg.startsWith('--auto-approve=')) {
      autoApprove = arg.split('=')[1].toLowerCase() == 'true';
    } else if (arg.startsWith('--build-web=')) {
      buildWeb = arg.split('=')[1].toLowerCase() == 'true';
    }
  }

  final startTime = DateTime.now();

  try {
    // STEP 1: Generate
    print('🚀 STEP 1/4: Generating $count article(s)...');
    final genProcess = await Process.run('dart', [
      'run',
      'tools/blog_ai/generate_ai_articles.dart',
      '--count=$count',
    ]);
    
    if (genProcess.exitCode != 0) {
      print('❌ Generation failed:');
      print(genProcess.stderr);
      exit(1);
    }
    print(genProcess.stdout);
    print('✅ STEP 1/4: Generate... OK');

    // STEP 2: Approve
    List<String> newSlugs = [];
    if (autoApprove) {
      print('\n🚀 STEP 2/4: Automatically approving new drafts...');
      final indexFile = File('blog_drafts/_index.json');
      if (indexFile.existsSync()) {
        final List<dynamic> index = jsonDecode(indexFile.readAsStringSync());
        final now = DateTime.now();
        
        for (var i = 0; i < index.length; i++) {
          final article = index[i] as Map<String, dynamic>;
          if (article['status'] == 'draft') {
            article['status'] = 'approved';
            newSlugs.add(article['slug']);
          }
        }
        
        indexFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(index));
        print('✅ Approved ${newSlugs.length} articles: ${newSlugs.join(", ")}');
      }
      print('✅ STEP 2/4: Approve... OK');
    } else {
      print('\n🚀 STEP 2/4: Approve... SKIPPED (auto-approve=false)');
    }

    // STEP 3: Import
    print('\n🚀 STEP 3/4: Importing approved articles...');
    final importProcess = await Process.run('dart', [
      'run',
      'tools/blog_ai/import_to_blog.dart',
      '--all-approved',
    ]);
    
    if (importProcess.exitCode != 0) {
      print('❌ Import failed:');
      print(importProcess.stderr);
      exit(1);
    }
    print(importProcess.stdout);
    print('✅ STEP 3/4: Import... OK');

    // STEP 4: Build Web
    if (buildWeb && File('pubspec.yaml').existsSync()) {
      print('\n🚀 STEP 4/4: Building Flutter Web...');
      final buildProcess = await Process.run('flutter', ['build', 'web']);
      if (buildProcess.exitCode != 0) {
        print('⚠️ Web build failed, but import was successful.');
        print(buildProcess.stderr);
      } else {
        print('✅ Web build completed successfully.');
      }
      print('✅ STEP 4/4: Build... OK');
    } else {
      print('\n🚀 STEP 4/4: Build... SKIPPED');
    }

    final duration = DateTime.now().difference(startTime);
    print('\n' + '═' * 60);
    print('🎉 PIPELINE COMPLETED SUCCESSFULLY!');
    print('⏱️ Total time: ${duration.inSeconds}s');
    if (newSlugs.isNotEmpty) {
      print('📝 Articles processed:');
      for (final slug in newSlugs) {
        print('   - $slug');
      }
    }
    print('═' * 60 + '\n');

  } catch (e) {
    print('\n❌ Pipeline FATAL ERROR: $e');
    exit(1);
  }
}
