# Copyright (C) 2020  Sutou Kouhei <kou@clear-code.com>
#
# This library is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library.  If not, see <http://www.gnu.org/licenses/>.

class ParserTest < Test::Unit::TestCase
  def setup
    @slim_file = Tempfile.new(["test", ".slim"])
  end

  def parse(content)
    @slim_file.rewind
    @slim_file.print(content)
    @slim_file.rewind
    GetTextSlim::Parser.parse(@slim_file.path)
  end

  def assert_parse(expected, content)
    assert_equal(normalize_expected(expected),
                 normalize_actual(parse(content)))
  end

  def normalize_expected(messages)
    messages.collect do |message|
      default = {
        :msgid        => nil,
        :msgid_plural => nil,
        :msgctxt      => nil,
        :msgstr       => nil,
        :separator    => nil,
        :references   => nil,
      }
      default.merge(message)
    end
  end

  def normalize_actual(po)
    po.collect do |po_entry|
      {
        :msgid        => po_entry.msgid,
        :msgid_plural => po_entry.msgid_plural,
        :msgctxt      => po_entry.msgctxt,
        :msgstr       => po_entry.msgstr,
        :separator    => po_entry.separator,
        :references   => po_entry.references,
      }
    end
  end

  def test_encoding_magic_comment
    assert_parse([
                   {
                     :msgid => "こんにちは".encode("cp932"),
                     :references => ["#{@slim_file.path}:3"],
                   }
                 ],
                 <<-SLIM.encode("cp932"))
-# -*- coding: cp932 -*-
p
  = _("こんにちは")
                 SLIM
  end

  def test_no_paren
    assert_parse([
                   {
                     :msgid => "Hello",
                     :references => ["#{@slim_file.path}:2"],
                   }
                 ],
                 <<-SLIM.encode("cp932"))
p
  = _ "Hello"
                 SLIM
  end
end
