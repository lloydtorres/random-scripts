scriptId = 'com.lloydtorres.imgur'
scriptTitle = 'Imgur Connector'

-- Lua script to enable browsing Imgur using the Myo.
-- A lot of the code was taken from the Myo SDK docs.

-- Variables

fistMade = false -- Flags for holding fist
referenceRoll = myo.getRoll()
currentRoll = referenceRoll

-- Effects

function nextPicture()
	myo.keyboard("right_arrow","press")
    myo.notifyUserAction()
end

function prevPicture()
	myo.keyboard("left_arrow","press")
    myo.notifyUserAction()
end

function scrollUp()
	myo.keyboard("up_arrow","press")
end

function scrollDown()
	myo.keyboard("down_arrow","press")
end

function resizePicture()
	myo.keyboard("return","press")
    myo.notifyUserAction()
end

-- Helpers

function conditionallySwapWave(pose) -- Changes waveIn/waveOut to be waveLeft/waveRight instead
    if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

-- Callbacks

function onPoseEdge(pose, edge)

    pose = conditionallySwapWave(pose)

    -- Other gestures
    if myo.isUnlocked() and edge == "on" then

        pose = conditionallySwapWave(pose)

        if pose == "waveOut" then
            nextPicture()
            myo.unlock("timed")
        elseif pose == "waveIn" then
            prevPicture()
            myo.unlock("timed")
        elseif pose == "fingersSpread" then
            resizePicture()
            myo.unlock("timed")
        elseif pose == "fist" then -- Sets up fist movement
            myo.unlock("hold")
            referenceRoll = myo.getRoll()
            fistMade = true
        end

    end

    if pose == "fist" and edge == "off" then
        fistMade = false
        myo.unlock("timed")
    end

end

function onPeriodic()
    -- Lock after inactivity

    currentRoll = myo.getRoll()

    if fistMade then -- Moves page when fist is held and Myo is rotated
        subtractive = currentRoll - referenceRoll
        if subtractive > 0.12  then
            scrollDown()
        elseif subtractive < -0.12 then
            scrollUp() 
        end
    end

end

function onForegroundWindowChange(app, title)
    return string.match(title,"%- Imgur %-") or string.match(title,"%- Imgur")
end

function activeAppName()
    return "Imgur"
end

function onActiveChange(isActive)
    if not isActive then
        unlocked = false
    end
end
