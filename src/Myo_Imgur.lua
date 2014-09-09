scriptId = 'es.lloydtorr.imgur'

-- Lua script to enable browsing Imgur using the Myo.
-- A lot of the code was taken from the Myo SDK docs.

-- Variables

unlocked = false

fistMade = false
referenceRoll = myo.getRoll()
currentRoll = referenceRoll

UNLOCKED_TIMEOUT = 3000

-- Effects

function nextPicture()
	myo.keyboard("right_arrow","press")
end

function prevPicture()
	myo.keyboard("left_arrow","press")
end

function bitDown()
    myo.keyboard("down_arrow","press")
end

function bitUp()
    myo.keyboard("up_arrow","press")
end

function scrollUp()
	myo.keyboard("up_arrow","down")
end

function scrollDown()
	myo.keyboard("down_arrow","down")
end

function resizePicture()
	myo.keyboard("return","press")
end

function resetFist()
    fistMade = false
    referenceRoll = myo.getRoll()
    currentRoll = referenceRoll
end

-- Helpers

-- Makes use of myo.getArm() to swap wave out and wave in when the armband is being worn on
-- the left arm. This allows us to treat wave out as wave right and wave in as wave
-- left for consistent direction. The function has no effect on other poses.
function conditionallySwapWave(pose)
    if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

-- Unlock mechanism

function unlock()
    unlocked = true
    extendUnlock()
end

function extendUnlock()
    unlockedSince = myo.getTimeMilliseconds()
end

-- Callbacks

function onPoseEdge(pose, edge)

    -- Unlock
    if pose == "thumbToPinky" and myo.getArm() ~= "unknown" then
        if edge == "off" then
            -- Unlock when pose is released in case the user holds it for a while.
            unlock()
        elseif edge == "on" and not unlocked then
            -- Vibrate twice on unlock.
            -- We do this when the pose is made for better feedback.
            myo.vibrate("short")
            myo.vibrate("short")
            extendUnlock()
        end
    end

    -- Other gestures
    if unlocked and edge == "on" then

        pose = conditionallySwapWave(pose)

        if pose == "waveOut" then
            extendUnlock()
            myo.vibrate("short")
            nextPicture()
        elseif pose == "waveIn" then
            extendUnlock()
            myo.vibrate("short")
            prevPicture()
        elseif pose == "fingersSpread" then
            extendUnlock()
            resizePicture()
        elseif pose == "fist" and not fistMade then
            extendUnlock()
            referenceRoll = myo.getRoll()
            fistMade = true
            if myo.getXDirection() == "towardElbow" then
                referenceRoll = referenceRoll * -1
            end
        end

        if pose ~= "fist" then
            resetFist()
        end
    end
end

function onPeriodic()
    -- Lock after inactivity

    currentRoll = myo.getRoll()
    if myo.getXDirection() == "towardElbow" then
        currentRoll = currentRoll * -1
    end

    if unlocked then
        -- If we've been unlocked longer than the timeout period, lock.
        -- Activity will update unlockedSince, see extendUnlock() above.
        if myo.getTimeMilliseconds() - unlockedSince > UNLOCKED_TIMEOUT then
            unlocked = false
            myo.vibrate("short")
            myo.vibrate("short")
        end
    end

    if unlocked and fistMade then
        extendUnlock()
        subtractive = currentRoll - referenceRoll
        if subtractive > 0.2 and subtractive < 0.6 then
            bitDown()
        elseif subtractive > 0.6 then
            scrollDown()
        elseif subtractive < -0.2 and subtractive > -0.6 then
            bitUp() 
        elseif subtractive < -0.6 then
            scrollUp()
        end
    end

end

function onForegroundWindowChange(app, title)
    -- Here we decide if we want to control the new active app.
    local wantActive = false
    activeApp = ""

    wantActive = string.match(title,"%- Imgur %-") or string.match(title,"%- Imgur")
    activeApp = "Imgur"

    return wantActive
end

function activeAppName()
    -- Return the active app name determined in onForegroundWindowChange
    return activeApp
end

function onActiveChange(isActive)
    if not isActive then
        unlocked = false
    end
end