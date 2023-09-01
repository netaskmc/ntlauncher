import 'package:launcher_core/helpers.dart';
import 'package:path/path.dart' as p;

class Launcher {
  Options options;
  Future<void> launch() async {}

  void log(String level, String message) {
    print('lc: [$level] $message');
  }

  Launcher(this.options) {
    // this.options.root = Path.resolve(this.options.root);
    options.overrides ??= Overrides();
    options.overrides!.detached ??= true;

    options.overrides!.url ??= Url();
    options.overrides!.url!.meta ??= 'https://launchermeta.mojang.com';
    options.overrides!.url!.resource ??=
        'https://resources.download.minecraft.net';
    options.overrides!.url!.mavenForge ??=
        'http://files.minecraftforge.net/maven/';
    options.overrides!.url!.defaultRepoForge ??=
        'https://libraries.minecraft.net/';
    options.overrides!.url!.fallbackMaven ??=
        'https://search.maven.org/remotecontent?filepath=';

    options.overrides!.fw = Fw();
    options.overrides!.fw!.baseUrl ??=
        'https://github.com/ZekerZhayard/ForgeWrapper/releases/download/';
    options.overrides!.fw!.version ??= '1.5.6';
    options.overrides!.fw!.sh1 ??= 'b38d28e8b7fde13b1bc0db946a2da6760fecf98d';
    options.overrides!.fw!.size ??= 34715;

    options.directory = options.overrides?.directory ??
        p.join(options.root, 'versions',
            options.version.custom ?? options.version.version);
  }
}
