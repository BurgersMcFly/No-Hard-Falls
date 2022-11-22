// NoHardFalls, Cyberpunk 2077 mod that makes every fall safe
// Copyright (C) 2022 BurgersMcFly

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

@replaceMethod(LocomotionAirEvents)

protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let deathLandingFallingSpeed: Float;
    let hardLandingFallingSpeed: Float;
    let horizontalSpeed: Float;
    let isInSuperheroFall: Bool;
    let landingAnimFeature: ref<AnimFeature_Landing>;
    let landingType: LandingType;
    let maxAllowedDistanceToGround: Float;
    let playerVelocity: Vector4;
    let regularLandingFallingSpeed: Float;
    let safeLandingFallingSpeed: Float;
    let verticalSpeed: Float;
    let veryHardLandingFallingSpeed: Float;
    super.OnUpdate(timeDelta, stateContext, scriptInterface);
    if this.IsTouchingGround(scriptInterface) {
      this.m_resetFallingParametersOnExit = true;
      return;
    };
    this.m_resetFallingParametersOnExit = false;
    verticalSpeed = this.GetVerticalSpeed(scriptInterface);
    if this.m_updateInputToggles && verticalSpeed < this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("minFallHeightToConsiderInputToggles", 0.00)) {
      this.UpdateInputToggles(stateContext, scriptInterface);
    };
    if scriptInterface.IsActionJustPressed(n"Jump") {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
      return;
    };
    if StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.BerserkPlayerBuff") && verticalSpeed < this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("minFallHeightToEnterSuperheroFall", 0.00)) {
      stateContext.SetTemporaryBoolParameter(n"requestSuperheroLandActivation", true, true);
    };
    regularLandingFallingSpeed = stateContext.GetFloatParameter(n"RegularLandingFallingSpeed", true);
    safeLandingFallingSpeed = stateContext.GetFloatParameter(n"SafeLandingFallingSpeed", true);
    hardLandingFallingSpeed = stateContext.GetFloatParameter(n"HardLandingFallingSpeed", true);
    veryHardLandingFallingSpeed = stateContext.GetFloatParameter(n"VeryHardLandingFallingSpeed", true);
    deathLandingFallingSpeed = stateContext.GetFloatParameter(n"DeathLandingFallingSpeed", true);
    isInSuperheroFall = stateContext.IsStateActive(n"Locomotion", n"superheroFall");
    maxAllowedDistanceToGround = this.GetStaticFloatParameterDefault("maxDistToGroundFromSuperheroFall", 20.00);
    if isInSuperheroFall && !this.m_maxSuperheroFallHeight {
      this.StartEffect(scriptInterface, n"falling");
      this.PlaySound(n"lcm_falling_wind_loop", scriptInterface);
      if DefaultTransition.GetDistanceToGround(scriptInterface) >= maxAllowedDistanceToGround {
        this.m_maxSuperheroFallHeight = true;
        return;
      };
      landingType = LandingType.Superhero;
    } else {
      if verticalSpeed <= deathLandingFallingSpeed && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MeleeLeap) {
              landingType = LandingType.Regular;
              this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.RegularFall));
              playerVelocity = DefaultTransition.GetLinearVelocity(scriptInterface);
              horizontalSpeed = Vector4.Length2D(playerVelocity);
              if horizontalSpeed <= this.GetStaticFloatParameterDefault("maxHorizontalSpeedToAerialTakedown", 0.00) {
                this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.SafeFall));
              };
      } else {
        if verticalSpeed <= veryHardLandingFallingSpeed && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MeleeLeap) {
              landingType = LandingType.Regular;
              this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.RegularFall));
              playerVelocity = DefaultTransition.GetLinearVelocity(scriptInterface);
              horizontalSpeed = Vector4.Length2D(playerVelocity);
              if horizontalSpeed <= this.GetStaticFloatParameterDefault("maxHorizontalSpeedToAerialTakedown", 0.00) {
                this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.SafeFall));
              };
        } else {
          if verticalSpeed <= hardLandingFallingSpeed {
              landingType = LandingType.Regular;
              this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.RegularFall));
              playerVelocity = DefaultTransition.GetLinearVelocity(scriptInterface);
              horizontalSpeed = Vector4.Length2D(playerVelocity);
              if horizontalSpeed <= this.GetStaticFloatParameterDefault("maxHorizontalSpeedToAerialTakedown", 0.00) {
                this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.SafeFall));
              };
          } else {
            if verticalSpeed <= safeLandingFallingSpeed {
              landingType = LandingType.Regular;
              this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.RegularFall));
              playerVelocity = DefaultTransition.GetLinearVelocity(scriptInterface);
              horizontalSpeed = Vector4.Length2D(playerVelocity);
              if horizontalSpeed <= this.GetStaticFloatParameterDefault("maxHorizontalSpeedToAerialTakedown", 0.00) {
                this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.SafeFall));
              };
            } else {
              if verticalSpeed <= regularLandingFallingSpeed {
                if this.GetLandingType(stateContext) != EnumInt(LandingType.Regular) {
                  this.PlaySound(n"lcm_falling_wind_loop", scriptInterface);
                };
                landingType = LandingType.Regular;
              } else {
                landingType = LandingType.Off;
              };
            };
          };
        };
      };
    };
    stateContext.SetPermanentIntParameter(n"LandingType", EnumInt(landingType), true);
    stateContext.SetPermanentFloatParameter(n"ImpactSpeed", verticalSpeed, true);
    stateContext.SetPermanentFloatParameter(n"InAirDuration", this.GetInStateTime(), true);
    landingAnimFeature = new AnimFeature_Landing();
    landingAnimFeature.impactSpeed = verticalSpeed;
    landingAnimFeature.type = EnumInt(landingType);
    scriptInterface.SetAnimationParameterFeature(n"Landing", landingAnimFeature);
    this.SetAudioParameter(n"RTPC_Vertical_Velocity", verticalSpeed, scriptInterface);
    this.SetAudioParameter(n"RTPC_Landing_Type", Cast<Float>(EnumInt(landingType)), scriptInterface);
  }
