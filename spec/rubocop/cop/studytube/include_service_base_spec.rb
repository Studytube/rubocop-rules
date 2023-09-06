# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Studytube::IncludeServiceBase, :config do
  let(:config) { RuboCop::Config.new }

  context 'with offense' do
    it do
      expect_offense(<<~RUBY)
        class AnyService
        ^^^^^^^^^^^^^^^^ please include ServiceBase into a service class
          def self.call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class AnyService
          include ServiceBase

          def call
          end
        end
      RUBY
    end

    it do
      expect_offense(<<~RUBY)
        class AnyService
        ^^^^^^^^^^^^^^^^ please include ServiceBase into a service class
          include OtherBase

          def self.call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class AnyService
          include ServiceBase
          include OtherBase

          def call
          end
        end
      RUBY
    end

    it 'without ServiceBase' do
      expect_offense(<<~RUBY)
        class AnyService
        ^^^^^^^^^^^^^^^^ please include ServiceBase into a service class
          def call
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class AnyService
          include ServiceBase
          def call
          end
        end
      RUBY
    end

    it 'with attr_reader and without Servicebase' do
      expect_offense(<<~RUBY)
        class AnyService
        ^^^^^^^^^^^^^^^^ please include ServiceBase into a service class
          attr_reader :params

          def initialize(params)
            @params = params
          end

          def self.call
            puts '1'
          end
        end
      RUBY
    end
  end

  context 'without offense' do
    it 'with include ServiceBase' do
      expect_no_offenses(<<~RUBY)
        class AnyService
          include ServiceBase

          def call
          end
        end
      RUBY
    end

    it 'with include ::ServiceBase' do
      expect_no_offenses(<<~RUBY)
        class AnyService
          include ::ServiceBase

          def call
          end
        end
      RUBY
    end

    it 'without ServiceBase and call method' do
      expect_no_offenses(<<~RUBY)
        class AnyService
        end
      RUBY
    end

    it 'when class has parent class' do
      expect_no_offenses(<<~RUBY)
        class AnyService < ParentService
          def call
          end
        end
      RUBY
    end

    it 'when call method has args' do
      expect_no_offenses(<<~RUBY)
        class AnyService
          def call(args)
          end
        end
      RUBY
    end

    it 'when self.call has args' do
      expect_no_offenses(<<~RUBY)
        class AnyService
          def self.call(args)
          end
        end
      RUBY
    end
  end
end
