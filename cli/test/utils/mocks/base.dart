const mockNames = [
  'pkg1',
  'pkg2',
  'pkg3',
  'pritty',
  'teapot',
  'fox',
  'tree',
  'rocket',
  'engine',
  'cloud',
  'wizard',
  'snake',
  'package',
];

const mockScopedNames = [
  ('pkg1', scope: 'org1'),
  ('pkg2', scope: 'org1'),
  ('pkg3', scope: 'org1'),
  ('pkg2', scope: 'org2'),
  ('pkg3', scope: 'org2'),
  ('compiler', scope: 'petite'),
  ('core', scope: 'petite'),
  ('cli', scope: 'petite'),
  ('compiler', scope: 'rocket'),
  ('core', scope: 'rocket'),
  ('cli', scope: 'rocket'),
  ('node', scope: 'rocket'),
  ('dart', scope: 'rocket'),
  ('haskell', scope: 'rocket'),
];

const mockAuthors = [
  (name: 'cowsay', email: 'cowsay@example.com'),
  (name: 'foo', email: 'foo@example.com'),
  (name: 'bar', email: 'bar@example.com'),
  (name: 'qux', email: 'qux@example.com'),
  (name: 'pritt', email: 'pritt@pritt.com'),
  (name: 'John Doe', email: 'jdoe@pritt.com'),
  (name: 'Nike Okoronkwo', email: 'neokoronkwo@pritt.com'),
  (name: 'Madison Adenuga', email: 'madenuga@pritt.com'),
  (name: 'Michael Phillips', email: 'mphillips@pritt.com'),
];

const languages = ['rust', 'cpp', 'c', 'dart'];
