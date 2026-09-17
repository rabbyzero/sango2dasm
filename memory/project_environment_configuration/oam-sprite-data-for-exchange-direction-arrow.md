# OAM Sprite Data for Exchange Direction Arrow

- **Category:** project_environment_configuration
- **Memory ID:** 4c9b17d6-c17c-4462-8b9c-43fae383af41
- **Keywords:** OAM data, sprite rendering, $DC94, ExchangeArrowOam

## Content

The data at $DC94 is OAM sprite data used to render the exchange direction arrow, consisting of Y, tile ($04), attribute, X, and terminator ($80). It is passed as a pointer to `B1F_SpriteOamWriterSimple` during arrow rendering in the Officer Exchange Scene.
