/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import {
  Box,
  Button,
  Input,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useLocalState } from '../backend';

export const meta = {
  title: 'ProgressBar',
  render: () => <Story />,
};

const Story = (props) => {
  const [progress, setProgress] = useLocalState('progress', 0.5);
  const [color, setColor] = useLocalState('color', '');

  const color_data = color
    ? { color: color }
    : {
        ranges: {
          good: [0.5, Infinity],
          bad: [-Infinity, 0.1],
          average: [0, 0.5],
        },
      };

  return (
    <Section>
      <ProgressBar {...color_data} minValue={-1} maxValue={1} value={progress}>
        Value: {Number(progress).toFixed(1)}
      </ProgressBar>
      <Box mt={1}>
        <LabeledList mt="2em">
          <LabeledList.Item label="Adjust value">
            <Button
              content="-0.1"
              onClick={() => setProgress(progress - 0.1)}
            />
            <Button
              content="+0.1"
              onClick={() => setProgress(progress + 0.1)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Override color">
            <Input value={color} onChange={(value) => setColor(value)} />
          </LabeledList.Item>
        </LabeledList>
      </Box>
    </Section>
  );
};
