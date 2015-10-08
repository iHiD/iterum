# Iterum
A message replayer for Propono

## Important Information

This is extracted from Meducation's codebase for easy reference on how to replay messages. We've used it for two years without issue, but we've not put a lot of thought or love into open-sourcing it, so tread with a small degree of awareness.

## To use it

Setup `config/propono.yml`

Run with:
```
bundle exec rake iterum:reprocess_failed[APPLICATION_NAME,TOPIC,COUNT] ENV=production
```

The initial commit is an extract from code written by [Malcolm Landon](https://github.com/malcyl), so all credit to him. 

Enjoy :blue_heart:
