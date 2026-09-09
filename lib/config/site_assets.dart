class SiteAssets {
  static const logo = 'assets/website/logo.png';
  static const heroSlide1 = 'assets/website/hero_slide_1.webp';
  static const heroImg = 'assets/website/hero_img.webp';

  static const menAll = 'assets/website/cat_all.webp';
  static const menBoxy = 'assets/website/cat_boxy.png';
  static const menLongSleeve = 'assets/website/cat_longsleeve.png';
  static const menTops = 'assets/website/cat_black_tee.jpg';
  static const menAccessories = 'assets/website/cat_bags_tile.webp';

  static const womenAll = 'assets/website/cat_women_all.jpg';
  static const womenBoxy = 'assets/website/cat_women_boxy.jpg';
  static const womenLongSleeve = 'assets/website/cat_women_longsleeve.jpg';
  static const womenTops = 'assets/website/cat_women_tops.jpg';
  static const womenAccessories = 'assets/website/cat_women_accessories.jpg';

  static const promoMenLeft = 'assets/website/promo_left.png';
  static const promoMenRight = 'assets/website/promo_right.webp';
  static const promoWomenLeft = 'assets/website/promo_women_left.jpg';
  static const promoWomenRight = 'assets/website/promo_women_right.jpg';

  static const capThumb = 'assets/website/cap_thumb.webp';

  static String categoryTile(String slug, {required bool women}) {
    final key = slug.toLowerCase().replaceAll('_', ' ').trim();
    final map = women ? _women : _men;
    return map[key] ?? map['all'] ?? menAll;
  }

  static const Map<String, String> _men = {
    'all': menAll,
    'boxy': menBoxy,
    'long sleeve': menLongSleeve,
    'long-sleeve': menLongSleeve,
    'longsleeve': menLongSleeve,
    'tops': menTops,
    'top': menTops,
    't-shirt': menTops,
    'tshirt': menTops,
    'shirt': menTops,
    'tee': menTops,
    'accessories': menAccessories,
    'accessory': menAccessories,
    'bags': menAccessories,
    'bag': menAccessories,
    'caps': capThumb,
    'cap': capThumb,
  };

  static const Map<String, String> _women = {
    'all': womenAll,
    'boxy': womenBoxy,
    'long sleeve': womenLongSleeve,
    'long-sleeve': womenLongSleeve,
    'longsleeve': womenLongSleeve,
    'tops': womenTops,
    'top': womenTops,
    't-shirt': womenTops,
    'tshirt': womenTops,
    'shirt': womenTops,
    'tee': womenTops,
    'accessories': womenAccessories,
    'accessory': womenAccessories,
    'bags': womenAccessories,
    'bag': womenAccessories,
    'caps': capThumb,
    'cap': capThumb,
  };
}
