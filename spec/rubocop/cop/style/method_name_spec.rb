# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe MethodName, :config do
        subject(:cop) { described_class.new(config) }

        shared_examples 'never accepted' do
          it 'registers an offence for mixed snake case and camel case' do
            inspect_source(cop, ['def visit_Arel_Nodes_SelectStatement',
                                 'end'])
            expect(cop.offences).to have(1).item
            expect(cop.highlights).to eq(['visit_Arel_Nodes_SelectStatement'])
          end

          it 'registers an offence for capitalized camel case' do
            inspect_source(cop, ['def MyMethod',
                                 'end'])
            expect(cop.offences).to have(1).item
            expect(cop.highlights).to eq(['MyMethod'])
          end
        end

        shared_examples 'always accepted' do
          it 'accepts one line methods' do
            inspect_source(cop, "def body; '' end")
            expect(cop.offences).to be_empty
          end

          it 'accepts operator definitions' do
            inspect_source(cop, ['def +(other)',
                                 '  # ...',
                                 'end'])
            expect(cop.offences).to be_empty
          end
        end

        context 'when configured for snake_case' do
          let(:cop_config) { { 'EnforcedStyle' => 'snake_case' } }

          it 'registers an offence for camel case in instance method name' do
            inspect_source(cop, ['def myMethod',
                                 '  # ...',
                                 'end'])
            expect(cop.offences).to have(1).item
            expect(cop.highlights).to eq(['myMethod'])
          end

          it 'registers an offence for camel case in singleton method name' do
            inspect_source(cop, ['def self.myMethod',
                                 '  # ...',
                                 'end'])
            expect(cop.offences).to have(1).item
            expect(cop.highlights).to eq(['myMethod'])
          end

          it 'accepts snake case in names' do
            inspect_source(cop, ['def my_method',
                                 'end'])
            expect(cop.offences).to be_empty
          end

          include_examples 'never accepted'
          include_examples 'always accepted'
        end

        context 'when configured for camelCase' do
          let(:cop_config) { { 'EnforcedStyle' => 'camelCase' } }

          it 'accepts camel case in instance method name' do
            inspect_source(cop, ['def myMethod',
                                 '  # ...',
                                 'end'])
            expect(cop.offences).to be_empty
          end

          it 'accepts camel case in singleton method name' do
            inspect_source(cop, ['def self.myMethod',
                                 '  # ...',
                                 'end'])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for snake case in names' do
            inspect_source(cop, ['def my_method',
                                 'end'])
            expect(cop.offences).to have(1).item
            expect(cop.highlights).to eq(['my_method'])
          end

          include_examples 'always accepted'
          include_examples 'never accepted'
        end

        context 'when configured with a bad value' do
          let(:cop_config) { { 'EnforcedStyle' => 'other' } }

          it 'fails' do
            expect { inspect_source(cop, ['def a', 'end']) }
              .to raise_error(RuntimeError)
          end
        end
      end
    end
  end
end
