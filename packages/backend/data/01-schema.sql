-- MySQL schema for Doctrine entities
-- Run automatically by official mysql image on first initialization

CREATE TABLE IF NOT EXISTS artists (
  ArtistId INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(120) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS albums (
  AlbumId INT AUTO_INCREMENT PRIMARY KEY,
  Title VARCHAR(160) NULL,
  ArtistId INT NULL,
  CONSTRAINT FK_albums_artist FOREIGN KEY (ArtistId)
    REFERENCES artists(ArtistId)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS genres (
  GenreId INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(120) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS media_types (
  MediaTypeId INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(120) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
