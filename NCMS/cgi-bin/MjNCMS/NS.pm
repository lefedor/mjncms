package MjNCMS::NS;

#B-Tree/Nested sets structure managemant module
#(C) possible cubvavk@nysnxzi.eh [Article author], site coding was broken, can't recognize
#Docs, src:
#http://webscript.ru/stories/04/09/01/8197045
#http://webscript.ru/stories/05/01/24/6319028
#++ Some mine fixes [Fedor F Lejepekov, ffl.public@gmail.com] 
#Comments are in Russian, but they almost all are dumb, don't worry about them. Should be wiped :).
# This module May/Should be rewritten :). But currently is in fine working condition.

use common::sense;
use FindBin;
use lib "$FindBin::Bin/../";

use MjNCMS::Config qw/:vars /;
use MjNCMS::Service qw/:subs /;

sub new {
# Получаем ссылку на переменную и входные параметры
    my ($self, $common) = @_;
# Описываем переменную, как ссылку на хеш хешей
    $self = {
             id    => 'id',        # имя поля таблицы - идентификатор
             left  => 'left_key',  # имя поля таблицы - левый ключ
             right => 'right_key', # имя поля таблицы - правый ключ
             level => 'level',     # имя поля таблицы - уровень
             multi => 'group',     # имя поля таблицы - идентификатор дерева
             table => undef,       # имя таблицы
             DBI   => undef,       # подключение к базе данных
             type  => 'N',         # мультидерево или нет -Y/N 
             order => 'B',         # порядок вставки, перемещения B/T - bottom/top
             unit  => {            # текущий (выбранный) элемент
                       id    => undef,   # идентификатор элемента
                       left  => undef,   # левый ключ элемента
                       right => undef,   # правый ключ элемента
                       level => undef,   # уровень элемента
                       multi => undef,   # идентификатор дерева элемента
                      },
            };
# Обработка входных параметров
    $self->{'id'} = $$common{'id'} if $$common{'id'};
    $self->{'type'} = $$common{'type'} && $$common{'type'} eq 'multi' ? 'M' : 'N';
    $self->{'order'} = $$common{'order'} && $$common{'order'} eq 'top' ? 'T' : 'B';
    $self->{'left'} = $$common{'left'} if $$common{'left'};
    $self->{'right'} = $$common{'right'} if $$common{'right'};
    $self->{'level'} = $$common{'level'} if $$common{'level'};
    $self->{'multi'} = $$common{'multi'} if $$common{'multi'};
    $self->{'table'} = $$common{'table'} if $$common{'table'};
    $self->{'DBI'} = $$common{'DBI'} if $$common{'DBI'};
# "благословление" объекта на работу ;-)
    bless $self;
    return $self;
}

sub insert_unit {
# Получаем объект, идентификатор родителя и идентификатор дерева
# 2й аргумент - может иметь флаг - не экранировать доп поля при вставке - {'_use_noquote'}
    my ($self, %common)= @_;
# Инициализируем идентификатор дерева
    my $catalog = $common{'tree'} || 1;
# Инициализируем идентификатор родителя
    my $under = $common{'under'} || 'root';
# Определяем порядок создания (место в списке)
    my $order = $common{'order'} || undef;
#Fedor: Поля
    my $noquote = $common{'_use_noquote'};
    my $fields_data = $common{'fields_data'} || undef;
# Объявляем локальные переменные
    my ($key, $level);
# Если родитель корень дерева
    if ($under eq 'root') {
# если вставка в конец списка левый ключ создаваемого выбирается как
# максимальный правый ключ дерева + 1, уровень узла - 1
        if (($order && $order eq 'top') || ($self->{'order'} eq 'T')) {
            $level = 1; $key = 1            
        } else {
            my $sql = 'SELECT MAX('.$self->{'right'}.') + 1 FROM '.$self->{'table'}.
                ($self->{'type'} eq 'M' ? ' WHERE '.$self->{'multi'}.'= \''.$catalog.'\'' : '');
            my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
            $key = $sth->fetchrow_arrayref()->[0];
            $sth->finish();
            $level = 1;
            $key = $key || 1
        }
# Если родитель определен, то левый ключ создаваемого узла будет равным
# правому ключу родительского узла, уровень - родительский + 1
    } else {
        my $sql = 'SELECT '.$self->{'right'}.', '.$self->{'left'}.', '.$self->{'level'}.
                  ($self->{'type'} eq 'M' ? ', '.$self->{'multi'} : '').
                  ' FROM '.$self->{'table'}.' WHERE '.$self->{'id'}.' = \''.$under.'\'';
        my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
        my $row = $sth->fetchrow_arrayref(); $sth->finish();
        $key = ($order && $order eq 'top') || ($self->{'order'} eq 'T') ? $$row[1] + 1: $$row[0];
        $level = $$row[2] + 1;
# Если у нас мультидерево, то переопределяем идентификатор дерева
# относительно родительского узла
        $catalog = $$row[3] || undef;
    }
# Обновляем ключи дерева для создания пустого промежутка
    $self->{'DBI'}->do('UPDATE '.$self->{'table'}.' SET '.
        $self->{'right'}.' = '.$self->{'right'}.' + 2, '.
        $self->{'left'}.' = IF('.$self->{'left'}.' >= '.$key.', '.$self->{'left'}.
        ' + 2, '.$self->{'left'}.') WHERE '.$self->{'right'}.' >= '.$key.
        ($self->{'type'} eq 'M' ? ' AND '.$self->{'multi'}.'= \''.$catalog.'\'' : ''));
# Создаем новый узел
#Fedor: вставка доп полей 
my $addict_q = '';
if (defined($fields_data)) {

foreach my $qkey (keys %{$fields_data}) {
        $addict_q .= ' '.$qkey.' = ' . ($noquote? $$fields_data{$qkey}.', ' : $self->{'DBI'}->quote($$fields_data{$qkey}).', ');
}
}
    $self->{'DBI'}->do('INSERT INTO '.$self->{'table'}.' SET '.$addict_q.
        $self->{'left'}.' = '.$key.', '.$self->{'right'}.' = '.$key.' + 1, '.
        $self->{'level'}.' = '.$level.
        ($self->{'type'} eq 'M' ? ', '.$self->{'multi'}.'= \''.$catalog.'\'' : ''));
# Получаем идентификатор созданного узла и возвращаем его в качестве результата
    my $sth = $self->{'DBI'}->prepare('SELECT LAST_INSERT_ID()'); $sth->execute();
    my $id = $sth->fetchrow_arrayref()->[0];
    $sth->finish();
    return $id
}

sub select_unit {
# Получаем объект, идентификатор узла
    my $self = shift;
    $self->{'unit'}->{'id'} = shift;
# Производим выборку данных узла*
    my $sql = 'SELECT '.$self->{'left'}.' AS lk, '.
                        $self->{'right'}.' AS rk, '.
                        $self->{'level'}.' AS lv '.
                        ($self->{'type'} eq 'M' ? ', '.$self->{'multi'}.' AS cl' : '').
              ' FROM '.$self->{'table'}.
              ' WHERE '.$self->{'id'}.' = \''.$self->{'unit'}->{'id'}.'\'';
    my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
    my $row = $sth -> fetchrow_hashref();
    $sth -> finish();
# Если узел существует, то передаем данные в объект
    if ($row) {
        $self->{'unit'}->{'left'} = $row->{'lk'};
        $self->{'unit'}->{'right'} = $row->{'rk'};
        $self->{'unit'}->{'level'} = $row->{'lv'};
        $self->{'unit'}->{'multi'} = $row->{'cl'} if $row->{'cl'};
        return $self
    } else {croak("NestedSets failed: Your cann't select this unit, because unit ".$self->{'unit'}->{'id'}  ." is not exist!!!")}
}

sub delete_unit {
# Получаем данные: объект и идентификатор удаляемого узла
    my ($self, $unit) = @_;
# получаем параметры узла
    if ($unit) {$self = &select_unit($self, $unit)}
    elsif (!$self->{'unit'}->{'id'}) {croak("NestedSets failed: Your must first select unit, for detete it!!!")}
# Определяем смещение ключей после удаления
    my $skew = $self->{'unit'}->{'right'} - $self->{'unit'}->{'left'} + 1;
# Удаляем узел
    $self->{'DBI'}->do('DELETE FROM '.$self->{'table'}.' WHERE '.
                       $self->{'left'}.' >= '.$self->{'unit'}->{'left'}.
                       ' AND '.$self->{'right'}.' <= '.$self->{'unit'}->{'right'}.
                       ($self->{'type'} eq 'M' ? 
                        ' AND '.$self->{'multi'}.'= \''.$self->{'unit'}->{'multi'}.'\'' : '')
                      );
# Обновляем ключи дерева относительно смещения
#Fedor, перенёс последний AND за IF, ошибка sql синтаксиса
    $self->{'DBI'}->do('UPDATE '.$self->{'table'}.
                       ' SET '.
                        $self->{'left'}.' = IF('.$self->{'left'}.' > '.$self->{'unit'}->{'left'}.', '.$self->{'left'}.' - '.$skew.', '.$self->{'left'}.'), '.
                        $self->{'right'}.' = '.$self->{'right'}.' - '.$skew.
                       ' WHERE '.
                        $self->{'right'}.' > '.$self->{'unit'}->{'right'}.
                        ($self->{'type'} eq 'M' ? ' AND '.$self->{'multi'}.'= \''.$self->{'unit_select'}->{'multi'}.'\'' : '')
                      );
    return 1
}

sub _move_unit {
# Получаем данные: объект и данные для перемещения
    my ($self, $data) = @_;
# Проверяем возможность перемещения*
    if ($data->{'near'} >= $data->{'left'} && $data->{'near'} <= $data->{'right'}) {return 0}
# Определяем смещение ключей перемещаемого узла и смещение уровня
    my $skew_tree = $data->{'right'} - $data->{'left'} + 1;
    my $skew_level = $data->{'level_new'} - $data->{'level'};
# Если перемещаем вверх по дереву
    if ($data->{'right'} < $data->{'near'}) {
# Определяем смещение ключей для дерева
        my $skew_edit = $data->{'near'} - $data->{'left'} + 1 - $skew_tree;
# Переносим узел и одновременно обновляем дерево
        $self->{'DBI'}->do('UPDATE '.$self->{'table'}.
                           ' SET '.
                            $self->{'left'}.' = IF('.$self->{'right'}.' <= '.$data->{'right'}.', '.
                             $self->{'left'}.' + '.$skew_edit.', IF('.$self->{'left'}.' > '.$data->{'right'}.', '.
                              $self->{'left'}.' - '.$skew_tree.', '.$self->{'left'}.')), '.
                            $self->{'level'}.' = IF('.$self->{'right'}.' <= '.$data->{'right'}.', '.
                             $self->{'level'}.' + '.$skew_level.', '.$self->{'level'}.'), '.
                            $self->{'right'}.' = IF('.$self->{'right'}.' <= '.$data->{'right'}.', '.
                             $self->{'right'}.' + '.$skew_edit.', IF('.$self->{'right'}.' <= '.$data->{'near'}.', '.
                              $self->{'right'}.' - '.$skew_tree.', '.$self->{'right'}.')) WHERE '.
                            $self->{'right'}.' > '.$data->{'left'}.' AND '.
                            $self->{'left'}.' <= '.$data->{'near'}.
                            ($self->{'type'} eq 'M' ? ' AND '.$self->{'multi'}.'= \''.$data->{'multi'}.'\'' : '')
                          );
# Если перемещаем вниз по дереву
    } else {
# Определяем смещение ключей для дерева
        my $skew_edit = $data->{'near'} - $data->{'left'} + 1;
# Переносим узел и одновременно обновляем дерево
        $self->{'DBI'}->do('UPDATE '.$self->{'table'}.
                           ' SET '.
                            $self->{'right'}.' = IF('.$self->{'left'}.' >= '.$data->{'left'}.', '.
                             $self->{'right'}.' + '.$skew_edit.', IF('.$self->{'right'}.' < '.$data->{'left'}.', '.
                              $self->{'right'}.' + '.$skew_tree.', '.$self->{'right'}.')), '.
                            $self->{'level'}.' = IF('.$self->{'left'}.' >= '.$data->{'left'}.', '.
                             $self->{'level'}.' + '.$skew_level.', '.$self->{'level'}.'), '.
                            $self->{'left'}.' = IF('.$self->{'left'}.' >= '.$data->{'left'}.', '.
                             $self->{'left'}.' + '.$skew_edit.', IF('.$self->{'left'}.' > '.$data->{'near'}.', '.
                              $self->{'left'}.' + '.$skew_tree.', '.$self->{'left'}.')) WHERE '.
                            $self->{'right'}.' > '.$data->{'near'}.' AND '.
                            $self->{'left'}.' < '.$data->{'right'}.
                            ($self->{'type'} eq 'M' ? ' AND '.$self->{'multi'}.'= \''.$data->{'multi'}.'\'' : '')
                      );
    }
    return 1
}

sub set_unit_under {
# Получаем данные: объект, перемещаемый узел, место перемещения, порядок перемещения
    my ($self, %common)= @_;
# перемещаемый узел
    my $unit = $common{'unit'} || undef;
# место перемещения
    my $under = $common{'under'} || undef;
# порядок перемещения (top - в начало, иначе - в конец списка)
    my $order = $common{'order'} || undef;
# объявляем переменную, которую будем передавать процедуре перемещения
    my $data;
# определяем данные перемещаемого узла
    if ($unit) {$self = &select_unit($self, $unit)}
    elsif (!$self->{'unit'}->{'id'}) {croak("NestedSets failed: Your must first select unit, for moving it!!!")}
# если место перемещения - корень дерева
    if (!$under || $under eq 'none' || $under eq 'root') {
# если порядок перемещения - начало списка
        if (($order && $order eq 'top') || $self->{'order'} eq 'T') {
            $data->{'near'} = 0;
            $data->{'level_new'} = 1
        } else {
# иначе выбираем максимальное значение ключа дерева
            my $sql = 'SELECT MAX('.$self->{'right'}.') AS num FROM '.$self->{'table'}.
                      ($self->{'type'} eq 'M' ? 
                       ' WHERE '.$self->{'multi'}.'='.$self->{'unit'}->{'multi'} : '');
            my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
            my $row = $sth->fetchrow_hashref();
            $sth->finish();
            if ($row) {$data->{'near'} = $$row{'num'}; $data->{'level_new'} = 1}
            else {croak("NestedSets failed: The place of moving is not determined, check up his!!!")}
        }
# иначе получаем данные места перемещения
    } else {
        my $sql = 'SELECT '.
                 $self->{'left'}.' AS lk, '.
                 $self->{'right'}.' AS rk, '.
                 $self->{'level'}.' AS lv FROM '.$self->{'table'}.
               ' WHERE '.$self->{'id'}.' = \''.$under.'\''.
                ($self->{'type'} eq 'M' ? 
                  ' AND '.$self->{'multi'}.'= \''.$self->{'unit'}->{'multi'}.'\'' : '');
        my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
        my $row = $sth->fetchrow_hashref(); $sth->finish();
# в зависимости от порядка перемещения берем либо правый, либо левый ключ
        if ($row && (($order && $order eq 'top') || $self->{'order'} eq 'T')) {
            $data->{'near'} = $$row{'lk'};
            $data->{'level_new'} = $$row{'lv'} + 1
        } elsif ($row) {
            $data->{'near'} = $$row{'rk'} - 1;
            $data->{'level_new'} = $$row{'lv'} + 1
        } else {croak("NestedSets failed: The place of moving is not determined, check up his!!!")}
    }
# перебрасываем из объекта данные о перемещаемом узле
    $data->{'left'} = $self->{'unit'}->{'left'};
    $data->{'right'} = $self->{'unit'}->{'right'};
    $data->{'level'} = $self->{'unit'}->{'level'};
    $data->{'multi'} = $self->{'unit'}->{'multi'} || undef;
    $self->{'unit'} = undef;
# перемещаем узел
    &_move_unit($self, $data);
    return 1
}

sub set_unit_near {
# Получаем данные: объект, перемещаемый узел, место перемещения, порядок перемещения
    my ($self, %common)= @_;
# перемещаемый узел
    my $unit = $common{'unit'} || undef;
# место перемещения
    my $near = $common{'near'} || undef;
# порядок перемещения (top - в начало, иначе - в конец списка)
    my $order = $common{'order'} || undef;
# объявляем переменную, которую будем передавать процедуре перемещения
    my $data;
# определяем данные перемещаемого узла
    if ($unit) {$self = &select_unit($self, $unit)}
    elsif (!$self->{'unit'}->{'id'}) {croak("NestedSets failed: Your must first select unit, for moving it!!!")}
# определяем данные места перемещения - узла, рядом с которым
# будет располагаться перемещаемый узел
    my $sql = 'SELECT '.
                  $self->{'left'}.' AS lk, '.
                  $self->{'right'}.' AS rk, '.
                  $self->{'level'}.' AS lv FROM '.$self->{'table'}.
              ' WHERE '.$self->{'id'}.' = \''.$near.'\''.
                  ($self->{'type'} eq 'M' ?
                   ' AND '.$self->{'multi'}.'= \''.$self->{'unit'}->{'multi'}.'\'' : '');
    my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
# в зависимости от порядка перемещения берем либо правый, либо левый ключ
    if ($row && $order && $order eq 'before') {
        $data->{'near'} = $$row{'lk'} - 1;
        $data->{'level_new'} = $$row{'lv'}
    } elsif ($row) {
        $data->{'near'} = $$row{'rk'};
        $data->{'level_new'} = $$row{'lv'}
    } else {croak("NestedSets failed: The place of moving is not determined, check up his!!!")}
# перебрасываем из объекта данные о перемещаемом узле
    $data->{'left'} = $self->{'unit'}->{'left'};
    $data->{'right'} = $self->{'unit'}->{'right'};
    $data->{'level'} = $self->{'unit'}->{'level'};
    $data->{'multi'} = $self->{'unit'}->{'multi'} || undef;
    $self->{'unit'} = undef;
# перемещаем узел
    &_move_unit($self, $data);
    return 1
}


sub set_unit_level {
# Получаем данные: объект, перемещаемый узел, место перемещения, порядок перемещения
    my ($self, %common)= @_;
# перемещаемый узел
    my $unit = $common{'unit'} || undef;
# место перемещения
    my $move = $common{'move'} || undef;
    return 0 unless $move;
# порядок перемещения (top - в начало, иначе - в конец списка)
    my $order = $common{'order'} || undef;
# объявляем переменную, которую будем передавать процедуре перемещения
    my $data;
# определяем данные перемещаемого узла
    if ($unit) {$self = &select_unit($self, $unit)}
    elsif (!$self->{'unit'}->{'id'}) {croak("NestedSets failed: Your must first select unit, for moving it!!!")}
# если на уровень вверх
    if ($move eq 'up') {
# определяем данные места перемещения - узла, рядом с которым
# будет располагаться перемещаемый узел
        my $sql = 'SELECT '.
                      $self->{'right'}.' AS rk, '.
                      $self->{'level'}.' AS lv FROM '. $self->{'table'}.
                  ' WHERE '.
                      $self->{'left'}.' < '.$self->{'unit'}->{'left'}.' AND '.
                      $self->{'right'}.' > '.$self->{'unit'}->{'right'}.' AND '.
                      $self->{'level'}.' = '.$self->{'unit'}->{'level'}.' - 1 '.
                      ($self->{'type'} eq 'M' ?
                       ' AND '.$self->{'multi'}.'= \''.$self->{'unit'}->{'multi'}.'\'' : '');
        my $sth = $self -> {'DBI'} -> prepare($sql); $sth -> execute();
        my $row = $sth -> fetchrow_hashref();
        $sth -> finish();
        if ($row) {
            $data->{'near'} = $$row{'rk'};
            $data->{'level_new'} = $$row{'lv'}
        } else {return 0}
# если на уровень вниз
    } elsif ($move eq 'down') {
# определяем данные места перемещения - узла, новый родитель
        my $sql = 'SELECT '.
                      $self->{'right'}.' AS rk, '.
                      $self->{'left'}.' AS lk, '.
                      $self->{'level'}.' AS lv FROM '.$self->{'table'}.
                  ' WHERE '.
                      $self->{'right'}.' = '.$self->{'unit'}->{'left'}.' - 1'.
                      ($self->{'type'} eq 'M' ?
                       ' AND '.$self->{'multi'}.'= \''.$self->{'unit'}->{'multi'}.'\'' : '');
        my $sth = $self -> {'DBI'} -> prepare($sql); $sth -> execute();
        my $row = $sth -> fetchrow_hashref();
        $sth -> finish();
        if ($row && (($order && $order eq 'top') || $self->{'order'} eq 'T')) {
            $data->{'near'} = $$row{'lk'};
            $data->{'level_new'} = $$row{'lv'} + 1
        } elsif ($row) {
            $data->{'near'} = $$row{'rk'} - 1;
            $data->{'level_new'} = $$row{'lv'} + 1
        } else {return 0}
    } else {return 0}
# перебрасываем из объекта данные о перемещаемом узле
    $data->{'left'} = $self->{'unit'}->{'left'};
    $data->{'right'} = $self->{'unit'}->{'right'};
    $data->{'level'} = $self->{'unit'}->{'level'};
    $data->{'multi'} = $self->{'unit'}->{'multi'} || undef;
    $self->{'unit'} = undef;
# перемещаем узел
    &_move_unit($self, $data);
    return 1
}


sub set_unit_order {
# Получаем данные: объект, перемещаемый узел, порядок перемещения
    my ($self, %common)= @_;
# перемещаемый узел
    my $unit = $common{'unit'} || undef;
# место перемещения
    my $move = $common{'move'} || undef;
    return 0 unless $move;
# объявляем переменную, которую будем передавать процедуре перемещения
    my $data;
# определяем данные перемещаемого узла
    if ($unit) {$self = &select_unit($self, $unit)}
    elsif (!$self->{'unit'}->{'id'}) {croak("NestedSets failed: Your must first select unit, for moving it!!!")}
# определяем данные места перемещения - узла, за которым
# будет располагаться перемещаемый узел
    if ($move eq 'up') {
        my $sql = 'SELECT '.
                    $self->{'left'}.' AS lk '.
                  ' FROM '.$self->{'table'}.
                  ' WHERE '.
                    $self->{'right'}.' = '.$self->{'unit'}->{'left'}.' - 1 '.
                    ($self->{'type'} eq 'M' ?
                     ' AND '.$self->{'multi'}.'= \''.$self->{'unit'}->{'multi'}.'\'' : '');
        my $sth = $self -> {'DBI'} -> prepare($sql); $sth -> execute();
        my $row = $sth -> fetchrow_hashref();
        $sth -> finish();
        if ($row) {$data->{'near'} = $$row{'lk'} - 1} else {return 0}
    } elsif ($move eq 'down') {
        my $sql = 'SELECT '.
                    $self->{'right'}.' AS rk '.
                  ' FROM '.$self->{'table'}.
                  ' WHERE '.
                    $self->{'left'}.' = '.$self->{'unit'}->{'right'}.' + 1'.
                    ($self->{'type'} eq 'M' ?
                     ' AND '.$self->{'multi'}.'= \''.$self->{'unit'}->{'multi'}.'\'' : '');
        my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
        my $row = $sth->fetchrow_hashref();
        $sth -> finish();
        if ($row) {$data->{'near'} = $$row{'rk'}} else {return 0}
    }
# перебрасываем из объекта данные о перемещаемом узле
    $data->{'left'} = $self->{'unit'}->{'left'};
    $data->{'right'} = $self->{'unit'}->{'right'};
    $data->{'level'} = $self->{'unit'}->{'level'};
# Так как работаем в перделах одного подчинения, то уровень не меняется
    $data->{'level_new'} = $self->{'unit'}->{'level'};
    $data->{'multi'} = $self->{'unit'}->{'multi'} || undef;
    $self->{'unit'} = undef;
# перемещаем узел
    &_move_unit($self, $data);
    return 1
}

sub get_parent_id {
# Получаем данные: объект, параметры
    my ($self, %common)= @_;
# перемещаемый узел
    my $unit = $common{'unit'} || undef;
# что возвращаем
    my $branch = $common{'branch'} || undef;
# объявляем переменную, массив идентификаторов
    my @data;
# определяем данные узла
    if ($unit) {$self = &select_unit($self, $unit)}
    elsif (!$self->{'unit'}->{'id'}) {croak("NestedSets failed: Your must first select unit, for using it!!!")}
# определяем, есть ли подчиненные узлы
    unless ($self->{'unit'}->{'level'} > 1) {return ['root']}
# Производим выборку ветви
    my $sql = 'SELECT '.$self->{'id'}.' FROM '.$self->{'table'}.
              ' WHERE '.
                $self->{'left'}.' < '.$self->{'unit'}->{'left'}.' AND '.
                $self->{'right'}.' > '.$self->{'unit'}->{'right'}.
# Если мультидерево, ограничение
                ($self->{'type'} eq 'M' ?
                 ' AND '.$self->{'multi'}.' = \''.$self->{'unit'}->{'multi'}.'\'' : '').
# Вся ветвь или непосредственный родитель
               ($branch && $branch eq 'all' ?
                ' ORDER BY '.$self->{'left'} :
                ' ORDER BY '.$self->{'left'}.' DESC LIMIT 1');
    my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
# Формируем массив
    while (my @row = $sth->fetchrow_array()) {push @data, $row[0]}
    $sth->finish();
# Возвращаем массив
    return \@data
}

sub get_parent_in_array {
# Получаем данные: объект, перемещаемый узел, место перемещения, порядок перемещения
    my ($self, %common)= @_;
# перемещаемый узел
    my $unit = $common{'unit'} || undef;
# что возвращаем
    my $branch = $common{'branch'} || undef;
# дополнительные поля запроса
    my $field = $common{'field'} || undef;
# если выбираем все поля
    $field = $self->{'table'}.'.*' if $field =~ /\*/;
# объявляем переменную, массив идентификаторов
    my @data;
# определяем данные узла
    if ($unit) {$self = &select_unit($self, $unit)}
    elsif (!$self->{'unit'}->{'id'}) {croak("NestedSets failed: Your must first select unit, for using it!!!")}
# определяем, есть ли подчиненные узлы
    unless ($self->{'unit'}->{'level'} > 1) {return [{id=>'root'}]}
# Производим выборку ветви
    my $sql = 'SELECT '.$self->{'id'}.', '.$self->{'left'}.', '.$self->{'right'}.', '.$self->{'level'}.
                ($field ? ', '.$field : '').
              ' FROM '.$self->{'table'}.
              ' WHERE '.
                $self->{'left'}.' < '.$self->{'unit'}->{'left'}.' AND '.
                $self->{'right'}.' > '.$self->{'unit'}->{'right'}.
# Если мультидерево, ограничение
                ($self->{'type'} eq 'M' ?
                 ' AND '.$self->{'multi'}.' = \''.$self->{'unit'}->{'multi'}.'\'' : '').
# Вся ветвь или непосредственный родитель
              ($branch && $branch eq 'all' ?
               ' ORDER BY '.$self->{'left'} :
               ' ORDER BY '.$self->{'level'}.' DESC LIMIT 1');
    my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {push @data, $row}
    $sth->finish();
# возвращаем массив
    #return {'d'=>\@data, 'sq'=>$sql};
    return \@data
}

sub get_child_id {
# Получаем данные: объект, перемещаемый узел, место перемещения, порядок перемещения
    my ($self, %common)= @_;
# перемещаемый узел
    my $unit = $common{'unit'} || undef;
# что выбираем
    my $branch = $common{'branch'} || undef;
# объявляем переменную, массив идентификаторов
    my @data;
# определяем данные узла
#Fedor: root hack
	my ($sth, $sql);
    if ($unit && $unit =~ /^\d+$/) {$self = &select_unit($self, $unit)}
    elsif (!$self->{'unit'}->{'id'}) {
		#special thing - get all tree from root receusively
		$unit = 'root'; 
		$self->{'unit'}->{'level'} = '0';
		my $sql = 'SELECT (MIN('.$self->{'left'}.')-1) as mleft, (MAX('.$self->{'right'}.')+1) as mright FROM '.$self->{'table'}.
              ' WHERE '.
                $self->{'level'}.' = 1 '.
                ($self->{'type'} eq 'M' ?
                 ' AND '.$self->{'multi'}.' = \''.$self->{'unit'}->{'multi'}.'\'' : '');
        $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
        ($self->{'unit'}->{'left'}, $self->{'unit'}->{'right'}) = $sth->fetchrow_array();
	}
# определяем, есть ли подчиненные узлы
    if ($self->{'unit'}->{'right'} - $self->{'unit'}->{'left'} == 1) {return []}
# Производим выборку ветви
    my $sql = 'SELECT '.$self->{'id'}.' FROM '.$self->{'table'}.
              ' WHERE '.
                $self->{'left'}.' > '.$self->{'unit'}->{'left'}.' AND '.
                $self->{'right'}.' < '.$self->{'unit'}->{'right'}.
# Если мультидерево, ограничение
                ($self->{'type'} eq 'M' ?
                 ' AND '.$self->{'multi'}.' = \''.$self->{'unit'}->{'multi'}.'\'' : '') .
# Вся ветвь или непосредственный родитель
#Fedor, упущена кавычка и лишний рассчёт в БД перед последним ORDER BY, исправлено, скобки кривые
              ($branch && $branch eq 'all' ?
               ' ORDER BY '.$self->{'left'} :
               ' AND '.$self->{'level'}.' = \''.($self->{'unit'}->{'level'}+ 1).'\' ORDER BY '.$self->{'left'});
    $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
    while (my @row = $sth->fetchrow_array()) {push @data, $row[0]}
    $sth->finish();
# возвращаем массив
    return \@data
}

sub get_child_in_array {
# Получаем данные: объект, перемещаемый узел, место перемещения, порядок перемещения
    my ($self, %common)= @_;
# перемещаемый узел
    my $unit = $common{'unit'} || undef;
# что выбираем
    my $branch = $common{'branch'} || undef;
# дополнительные поля запроса
    my $field = $common{'field'} || undef;
# если выбираем все поля
    $field = $self->{'table'}.'.*' if $field =~ /\*/;
# объявляем переменную, массив идентификаторов
    my @data;
# определяем данные узла
    if ($unit) {$self = &select_unit($self, $unit)}
    elsif (!$self->{'unit'}->{'id'}) {$unit = 'root'; $self->{'unit'}->{'level'} = '0'}
# определяем, есть ли подчиненные узлы
    unless ($unit eq 'root' || $self->{'unit'}->{'right'} - $self->{'unit'}->{'left'} > 1) {return [{id=>'none'}]}
# Производим выборку ветви
    my $sql = 'SELECT '.$self->{'id'}.', '.$self->{'left'}.', '.$self->{'right'}.', '.$self->{'level'}.
                ($field ? ', '.$field : '').
              ' FROM '.$self->{'table'}.
              ' WHERE '.
                $self->{'left'}.' > '.$self->{'unit'}->{'left'}.' AND '.
                $self->{'right'}.' < '.$self->{'unit'}->{'right'}.
# Если мультидерево, ограничение
                ($self->{'type'} eq 'M' ?
                 ' AND '.$self->{'multi'}.' = \''.$self->{'unit'}->{'multi'}.'\'' : '').
# Вся ветвь или непосредственный родитель
              ($branch && $branch eq 'all' ?
               ' ORDER BY '.$self->{'left'} :
               ' AND '.$self->{'level'}.' = \''.$self->{'unit'}->{'level'}.' + 1 ORDER BY '.$self->{'left'});
    my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {push @data, $row}
    $sth->finish();
# возвращаем массив
    return \@data
}

sub check_tree {
# Получаем данные: объект
    my ($self, $repair) = @_;
# Результат проверки
    my %data;
# Левый ключ ВСЕГДА меньше правого
    my $sql = 'SELECT '.($self->{'type'} eq 'M' ?
                         $self->{'multi'}.' AS multi' : 'COUNT('.$self->{'id'}.') AS num').
              ' FROM '.$self->{'table'}.
              ' WHERE '.$self->{'left'}.' >= '.$self->{'right'}.
              ($self->{'type'} eq 'M' ? ' GROUP BY '.$self->{'multi'} : '');
    my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {
        if ($self->{'type'} eq 'M') {$data{$$row{'multi'}} = 1}
        elsif ($$row{'num'} && $$row{'num'} > 0) {$data{'check'} = 'no'}
    }
    $sth->finish();
# Наименьший левый ключ ВСЕГДА равен 1
# Наибольший правый ключ ВСЕГДА равен двойному числу узлов
    $sql = 'SELECT '.($self->{'type'} eq 'M' ? $self->{'multi'}.' AS multi, ' : '').
               ' COUNT('.$self->{'id'}.') AS num, '.
               ' MIN('.$self->{'left'}.') AS lk, '.
               ' MAX('.$self->{'right'}.') AS rk'.
           ' FROM '.$self->{'table'}.
           ($self->{'type'} eq 'M' ? ' GROUP BY '.$self->{'multi'} : '');
    $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {
        unless ($$row{'lk'} == 1 && $$row{'rk'} / $$row{'num'} == 2) {
            if ($self->{'type'} eq 'M') {$data{$$row{'multi'}} = 1} else {$data{'check'} = 'no'}
        }
    }
    $sth->finish();
# Разница между правым и левым ключом ВСЕГДА нечетное число
    $sql = 'SELECT '.($self->{'type'} eq 'M' ?
                      $self->{'multi'}.' AS multi, ' : 'COUNT('.$self->{'id'}.') AS num, ').
               ' MOD(('.$self->{'right'}.' - '.$self->{'left'}.'), 2) AS os'.
           ' FROM '.$self->{'table'}.
           ' GROUP BY '.$self->{'id'}.
           ' HAVING os = 0';
    $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {
        if ($self->{'type'} eq 'M') {$data{$$row{'multi'}} = 1}
        elsif ($$row{'num'} && $$row{'num'} > 0) {$data{'check'} = 'no'}
    }
    $sth->finish();
# Если уровень узла нечетное число то тогда левый ключ ВСЕГДА нечетное число,
# то же самое и для четных чисел
    $sql = 'SELECT '.($self->{'type'} eq 'M' ?
                      $self->{'multi'}.' AS multi, ' : 'COUNT('.$self->{'id'}.') AS num, ').
               ' MOD(('.$self->{'left'}.' - '.$self->{'level'}.' + 2), 2) AS os'.
           ' FROM '.$self->{'table'}.
           ' GROUP BY '.$self->{'id'}.
           ' HAVING os = 1';
    $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {
        if ($self->{'type'} eq 'M') {$data{$$row{'multi'}} = 1}
        elsif ($$row{'num'} && $$row{'num'} > 0) {$data{'check'} = 'no'}
    }
    $sth->finish();
# Ключи ВСЕГДА уникальны, вне зависимости от того правый он или левый
    if ($self->{'type'} eq 'M') {
        my $sql = 'SELECT '.$self->{'multi'}.' AS multi'.
                  ' FROM '.$self->{'table'}.
                  ' GROUP BY '.$self->{'multi'};
        my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
        while (my $multi = $sth->fetchrow_hashref()) {
            my $sql = 'SELECT '.$self->{'left'}.' AS lk, '.$self->{'right'}.' AS rk'.
                      ' FROM '.$self->{'table'}.
                      ' WHERE '.$self->{'multi'}.' = '.$$multi{'multi'};
            my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
            my %check;
            while (my $row = $sth->fetchrow_hashref()) {
                if ($check{$$row{'lk'}}) {$data{$$multi{'multi'}} = 1} else {$check{$$row{'lk'}} = 1}
                if ($check{$$row{'rk'}}) {$data{$$multi{'multi'}} = 1} else {$check{$$row{'rk'}} = 1}
            }
            $sth->finish();
        }
        $sth->finish();
    } else {
        my $sql = 'SELECT '.$self->{'left'}.' AS lk, '.$self->{'right'}.' AS rk'.
                  ' FROM '.$self->{'table'};
        my $sth = $self->{'DBI'}->prepare($sql); $sth->execute();
        my %check;
        while (my $row = $sth->fetchrow_hashref()) {
            if ($check{$$row{'lk'}}) {$data{'check'} = 'no'} else {$check{$$row{'lk'}} = 1}
            if ($check{$$row{'rk'}}) {$data{'check'} = 'no'} else {$check{$$row{'rk'}} = 1}
        }
        $sth->finish();
    }
# Проверяем, найдены ли ошибки
    my $result = 'No error';
    if (%data && $repair eq 'repair') {$result = &repair_tree($self, %data)}
    elsif (%data && $repair ne 'repair') {$result = 'Found error! Not repaired!'}
    return $result
}

sub repair_tree {
# Получаем данные
    my ($self, %multi) = @_;
# Обработка дерева
    if ($self->{'type'} eq 'M') {
        foreach my $class (keys %multi) {
            $self->{'DBI'}->do('SET @count1 := -1');
            $self->{'DBI'}->do('SET @count2 := 0');
            $self->{'DBI'}->do('UPDATE '.$self->{'table'}.
                ' SET '.$self->{'left'}.' = @count1 := @count1 + 2, '.
                        $self->{'right'}.' = @count2 := @count2 + 2, '.
                        $self->{'level'}.' = 1'.
                ' WHERE '.$self->{'multi'}.' = \''.$class.'\''.
                ' ORDER BY '.$self->{'id'})
        }
    } else {
        $self->{'DBI'}->do('SET @count1 := -1');
        $self->{'DBI'}->do('SET @count2 := 0');
        $self->{'DBI'}->do('UPDATE '.$self->{'table'}.
            ' SET '.$self->{'left'}.' = @count1 := @count1 + 2, '.
                    $self->{'right'}.' = @count2 := @count2 + 2, '.
                    $self->{'level'}.' = 1'.
            ' ORDER BY '.$self->{'id'})
    }
    return 'Repair OK!';
}

1;
