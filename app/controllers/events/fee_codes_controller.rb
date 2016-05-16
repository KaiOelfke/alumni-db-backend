class Events::FeeCodesController < ApplicationController

  before_action :authenticate_user!

  def index
    @current_user = current_user
    if @current_user.is_super_user
      
      @feeCodes = Events::FeeCode.all

    else 
      raise Forbidden
    end
    
    success_response( @feeCodes.as_json())
  end


  def show
    @current_user = current_user

    if @current_user.is_super_user

      if /\A\d+\z/.match(params[:id])
        @feeCode = Events::FeeCode.where( "code = ? OR id = ?",
                                          params[:id],
                                          params[:id]).take
      else
        @feeCode = Events::FeeCode.where( code: params[:id]).take
      end

      if @feeCode
        success_response( @feeCode.as_json())
      else
        raise NotFound
      end

    else
      raise Forbidden
    end

  end

  def create
    @current_user = current_user

    if @current_user.is_super_user

        @feeCode = Events::FeeCode.new(create_feecode_params);

        if @feeCode.save
          success_response( @feeCode.as_json())
        else
          raise InternalServerError, record: @feeCode
        end

    else 
      raise Forbidden
    end

  end

  def update
    @current_user = current_user

    if @current_user.is_super_user

      @feeCode = Events::FeeCode.where( "code = ? OR id = ?",
                                        params[:code],
                                        params[:id]).take
      if @feeCode
        if @feeCode.update(update_feecode_params)
          success_response( @feeCode.as_json())
        else
          raise InternalServerError, record: @feeCode
        end        
      else 
        raise NotFound
      end

    else
      raise Forbidden
    end

  end

  def destroy
    @current_user = current_user

    if @current_user.is_super_user
      
      @feeCode = Events::FeeCode.where( "code = ? OR id = ?",
                                        params[:code],
                                        params[:id]).take

      if @feeCode
        @feeCode.delete_flag = true

        if @feeCode.save
          success_response( @feeCode.as_json())
        else
          raise InternalServerError, record: @feeCode
        end

      else
        raise NotFound
      end
    else
      raise Forbidden
    end

  end

  private

    def create_feecode_params
        params.require(:fee_code).permit(:user_id, :fee_id)
    end

    def update_feecode_params
        params.require(:fee_code).permit(:delete_flag)
    end
end
