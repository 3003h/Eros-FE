perl -i -pe 's/^(version:\s+\d+\.\d+\.)(\d+)(\+)(\d+)$/$1.$2.$3.($4+1)/e' pubspec.yaml
git add pubspec.yaml

