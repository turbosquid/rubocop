# encoding: utf-8

require 'spec_helper'

module Rubocop
  describe ProcessedSource do
    subject(:processed_source) do
      ProcessedSource.new(
        buffer,
        double('ast'),
        double('comments'),
        double('tokens'),
        diagnostics
      )
    end

    let(:diagnostics) { double('diagnostics') }

    let(:source) do
      [
        'def some_method',
        "  puts 'foo'",
        'end',
        'some_method'
      ].join("\n")
    end

    let(:buffer) do
      buffer = Parser::Source::Buffer.new('(string)', 1)
      buffer.source = source
      buffer
    end

    describe '#lines' do
      it 'is an array' do
        expect(processed_source.lines).to be_a(Array)
      end

      it 'has same number of elements as line count' do
        expect(processed_source.lines.size).to eq(4)
      end

      it 'contains lines as string without linefeed' do
        first_line = processed_source.lines.first
        expect(first_line).to eq('def some_method')
      end
    end

    describe '#[]' do
      context 'when an index is passed' do
        it 'returns the line' do
          expect(processed_source[2]).to eq('end')
        end
      end

      context 'when a range is passed' do
        it 'returns the array of lines' do
          expect(processed_source[2..3]).to eq(%w(end some_method))
        end
      end

      context 'when start index and length are passed' do
        it 'returns the array of lines' do
          expect(processed_source[2, 2]).to eq(%w(end some_method))
        end
      end
    end

    describe 'valid_syntax?' do
      let(:diagnostics) do
        [Parser::Diagnostic.new(level, 'message', double('location'))]
      end

      context 'when the source has diagnostic with error level' do
        let(:level) { :error }

        it 'returns false' do
          expect(processed_source.valid_syntax?).to be_false
        end
      end

      context 'when the source has diagnostic with error level' do
        let(:level) { :fatal }

        it 'returns false' do
          expect(processed_source.valid_syntax?).to be_false
        end
      end

      context 'when the source has diagnostic with error level' do
        let(:level) { :warning }

        it 'returns false' do
          expect(processed_source.valid_syntax?).to be_true
        end
      end

      context 'when the source has diagnostics with error and warning level' do
        let(:diagnostics) do
          [
            Parser::Diagnostic.new(:error, 'message', double('location')),
            Parser::Diagnostic.new(:warning, 'message', double('location'))
          ]
        end

        it 'returns false' do
          expect(processed_source.valid_syntax?).to be_false
        end
      end
    end
  end
end
