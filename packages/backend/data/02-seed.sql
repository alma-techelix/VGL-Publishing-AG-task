-- Seed sample data
INSERT INTO artists (Name) VALUES ('AC/DC'), ('Miles Davis'), ('Ludwig van Beethoven');
INSERT INTO genres (Name) VALUES ('Rock'), ('Jazz'), ('Classical');
INSERT INTO albums (Title, ArtistId) VALUES
  ('Back in Black', 1),
  ('Kind of Blue', 2),
  ('Symphony No.9', 3);
INSERT INTO media_types (Name) VALUES ('CD'), ('Digital'), ('Vinyl');
