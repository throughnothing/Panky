package Panky::Schema::Result::Obj;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Panky::Schema::Result::Obj

=cut

__PACKAGE__->table("obj");

=head1 ACCESSORS

=head2 key

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 value

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "key",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "value",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("key");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-09-18 22:49:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PMtGiuKO2EsCt0AssG1flQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
